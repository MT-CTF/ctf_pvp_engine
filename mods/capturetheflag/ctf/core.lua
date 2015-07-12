-- Registered
ctf.registered_on_load = {}
function ctf.register_on_load(func)
	table.insert(ctf.registered_on_load, func)
end
ctf.registered_on_save = {}
function ctf.register_on_save(func)
	table.insert(ctf.registered_on_save, func)
end
ctf.registered_on_init = {}
function ctf.register_on_init(func)
	table.insert(ctf.registered_on_init, func)
end
ctf.registered_on_new_team = {}
function ctf.register_on_new_team(func)
	table.insert(ctf.registered_on_new_team, func)
end
ctf.registered_on_territory_query = {}
function ctf.register_on_territory_query(func)
	table.insert(ctf.registered_on_territory_query, func)
end

function vector.distanceSQ(p1, p2)
	local x = p1.x - p2.x
	local y = p1.y - p2.y
	local z = p1.z - p2.z
	return x*x + y*y + z*z
end



-- Debug helpers
function ctf.error(area, msg)
	minetest.log("error", "CTF::" .. area .. " - " ..msg)
end
function ctf.log(area, msg)
	if area and area ~= "" then
		print("[CaptureTheFlag] (" .. area .. ") " .. msg)
	else
		print("[CaptureTheFlag] " .. msg)
	end
end
function ctf.action(area, msg)
	if area and area ~= "" then
		minetest.log("action", "[CaptureTheFlag] (" .. area .. ") " .. msg)
	else
		nubetest.log("action", "[CaptureTheFlag] " .. msg)
	end
end
function ctf.warning(area, msg)
	print("WARNING: [CaptureTheFlag] (" .. area .. ") " .. msg)
end



function ctf.init()
	ctf.log("init", "Initialising!")

	-- Set up structures
	ctf._defsettings = {}
	ctf.teams = {}
	ctf.players = {}
	ctf.claimed = {}

	-- See minetest.conf.example in the root of this subgame

	ctf.log("init", "Creating Default Settings")
	ctf._set("diplomacy",                  true)
	ctf._set("players_can_change_team",    true)
	ctf._set("allocate_mode",              0)
	ctf._set("maximum_in_team",            -1)
	ctf._set("default_diplo_state",        "war")
	ctf._set("node_ownership",             true)
	ctf._set("hud",                        true)

	for i = 1, #ctf.registered_on_init do
		ctf.registered_on_init[i]()
	end

	ctf.load()

	ctf.log("init", "Done!")
end

-- Set default setting value
function ctf._set(setting, default)
	ctf._defsettings[setting] = default

	if minetest.setting_get("ctf."..setting) then
		ctf.log("init", "- " .. setting .. ": " .. minetest.setting_get("ctf."..setting))
	elseif minetest.setting_get("ctf_"..setting) then
		ctf.log("init", "- " .. setting .. ": " .. minetest.setting_get("ctf_"..setting))
		ctf.warning("init", "deprecated setting ctf_"..setting..
				" used, use ctf."..setting.." instead.")
	end
end

function ctf.setting(name)
	local set = minetest.setting_get("ctf."..name) or
			minetest.setting_get("ctf_"..name)
	local dset = ctf._defsettings[name]
	if dset == nil then
		ctf.error("setting", "No such setting - " .. name)
		return nil
	end

	if set ~= nil then
		if type(dset) == "number" then
			return tonumber(set)
		elseif type(dset) == "bool" then
			return minetest.is_yes(set)
		else
			return set
		end
	else
		return dset
	end
end

function ctf.load()
	ctf.log("io", "Loading CTF state")
	local file = io.open(minetest.get_worldpath().."/ctf.txt", "r")
	if file then
		local table = minetest.deserialize(file:read("*all"))
		if type(table) == "table" then
			ctf.teams = table.teams
			ctf.players = table.players

			for i = 1, #ctf.registered_on_load do
				ctf.registered_on_load[i](table)
			end
			return
		end
	else
		ctf.log("io", "ctf.txt is not present in the world folder")
	end
end

function ctf.save()
	ctf.log("io", "Saving CTF state...")
	local file = io.open(minetest.get_worldpath().."/ctf.txt", "w")
	if file then
		local out = {
			teams = ctf.teams,
			players = ctf.players
		}

		for i = 1, #ctf.registered_on_save do
			local res = ctf.registered_on_save[i]()

			if res then
				for key, value in pairs(res) do
					out[key] = value
				end
			end
		end

		file:write(minetest.serialize(out))
		file:close()
		ctf.log("io", "Saved.")
	else
		ctf.error("io", "CTF file failed to save!")
	end
end

-- Get or add a team
function ctf.team(name) -- get or add a team
	if type(name) == "table" then
		if not name.add_team then
			ctf.error("team", "Invalid table given to ctf.team")
			return
		end

		ctf.log("team", "Defining team "..name.name)

		ctf.teams[name.name] = {
			data = name,
			spawn = nil,
			players = {}
		}

		for i = 1, #ctf.registered_on_new_team do
			ctf.registered_on_new_team[i](ctf.teams[name.name])
		end

		ctf.save()

		return ctf.teams[name.name]
	else
		if not ctf.teams[name] then
			ctf.warning("team", "'" .. name.."' does not exist!")
		end
		return ctf.teams[name]
	end
end

-- Count number of players in a team
function ctf.count_players_in_team(team)
	local count = 0
	for name, player in pairs(ctf.team(team).players) do
		count = count + 1
	end
	return count
end

function ctf.new_player(name)
	ctf.log("team", "Creating player " .. name)
	ctf.players[name] = {
		name = name
	}
end

-- get a player
function ctf.player(name)
	if not ctf.players[name] then
		ctf.new_player(name)
	end
	return ctf.players[name]
end

function ctf.player_or_nil(name)
	return ctf.players[name]
end

-- Player joins team
-- Called by /join or auto allocate.
-- /team join uses ctf.add_user()
function ctf.join(name, team, force)
	if not name or name == "" or not team or team == "" then
		ctf.log("team", "Missing parameters to ctf.join")
		return false
	end

	local player = ctf.player(name)

	if not force and not ctf.setting("players_can_change_team")
			and not player.team then
		ctf.action("teams", name .. " attempted to change to " .. team)
		minetest.chat_send_player(name, "You are not allowed to switch teams, traitor!")
		return false
	end

	if not ctf.team(team) then
		minetest.log("action", name .. " attempted to join " .. team .. ", which doesn't exist")
		minetest.chat_send_player(name, "No such team.")
		return false
	end

	if ctf.add_user(team, player) == true then
		minetest.log("action", name .. " joined team " .. team)
		minetest.chat_send_all(name.." has joined team "..team)

		if ctf.setting("hud") then
			ctf.hud.update(minetest.get_player_by_name(name))
		end

		return true
	end
	return false
end

-- TODO: refactor ctf.add_user etc
-- Add a player to a team in data structures
function ctf.add_user(team, user)
	local _team = ctf.team(team)
	local _user = ctf.player(user.name)
	if _team and user and user.name then
		if _user.team and ctf.team(_user.team) then
			ctf.teams[_user.team].players[user.name] = nil
		end

		user.team = team
		user.auth = false
		_team.players[user.name] = user
		ctf.players[user.name] = user
		ctf.save()

		return true
	else
		return false
	end
end

-- Cleans up the player lists
function ctf.clean_player_lists()
	ctf.log("utils", "Cleaning player lists")
	for _, str in pairs(ctf.players) do
		if str and str.team and ctf.teams[str.team] then
			ctf.log("utils", " - Adding player "..str.name.." to team "..str.team)
			ctf.teams[str.team].players[str.name] = str
		else
			ctf.log("utils", " - Skipping player "..str.name)
		end
	end
end

-- Get info for ctf.claimed
function ctf.collect_claimed()
	ctf.log("utils", "Collecting claimed locations")
	ctf.claimed = {}
	for _, team in pairs(ctf.teams) do
		for i = 1, #team.flags do
			if team.flags[i].claimed then
				table.insert(ctf.claimed, team.flags[i])
			end
		end
	end
end

-- Sees if the player can change stuff in a team
function ctf.can_mod(player,team)
	local privs = minetest.get_player_privs(player)

	if privs then
		if privs.team == true then
		 	return true
		end
	end

	if player and ctf.teams[team] and ctf.teams[team].players and ctf.teams[team].players[player] then
		if ctf.teams[team].players[player].auth == true then
			return true
		end
	end
	return false
end

-- post a message to a team board
function ctf.post(team, msg)
	if not ctf.team(team) then
		return false
	end

	if not ctf.team(team).log then
		ctf.team(team).log = {}
	end


	ctf.log("team", "message posted to team board")

	table.insert(ctf.team(team).log, 1, msg)
	ctf.save()

	return true
end

-- Automatic Allocation
function ctf.autoalloc(name, alloc_mode)
	ctf.log("autoalloc", "Getting autoallocation for " .. name)

	if alloc_mode == 0 then
		return
	end
	local max_players = ctf.setting("maximum_in_team")

	local mtot = false -- more than one team
	for key, team in pairs(ctf.teams) do
		mtot = true
		break
	end
	if not mtot then
		ctf.error("autoalloc", "No teams to allocate " .. name .. " to!")
		return
	end

	if alloc_mode == 1 then
		local index = {}

		for key, team in pairs(ctf.teams) do
			if max_players == -1 or ctf.count_players_in_team(key) < max_players then
				table.insert(index, key)
			end
		end

		if #index == 0 then
			ctf.error("autoalloc", "No teams to join!")
		else
			return index[math.random(1, #index)]
		end
	elseif alloc_mode == 2 then
		local one = nil
		local one_count = -1
		local two = nil
		local two_count = -1
		for key, team in pairs(ctf.teams) do
			local count = ctf.count_players_in_team(key)
			if (max_players == -1 or count < max_players) then
				if count > one_count then
					two = one
					two_count = one_count
					one = key
					one_count = count
				end

				if count > two_count then
					two = key
					two_count = count
				end
			end
		end

		if not one and not two then
			ctf.error("autoalloc", "No teams to join!")
		elseif one and two then
			if math.random() > 0.5 then
				return one
			else
				return two
			end
		else
			if one then
				return one
			else
				return two
			end
		end
	elseif alloc_mode == 3 then
		local smallest = nil
		local smallest_count = 1000
		for key, team in pairs(ctf.teams) do
			local count = ctf.count_players_in_team(key)
			if not smallest or count < smallest_count then
				smallest = key
				smallest_count = count
			end
		end

		if not smallest then
			ctf.error("autoalloc", "No teams to join!")
		else
			return smallest
		end
	else
		ctf.error("autoalloc", "Unknown allocation mode: "..ctf.setting("allocate_mode"))
	end
end

minetest.register_on_newplayer(function(player)
	local alloc_mode = tonumber(ctf.setting("allocate_mode"))
	if alloc_mode == 0 then
		return
	end
	local name = player:get_player_name()
	local team = ctf.autoalloc(name, alloc_mode)
	if team then
		ctf.log("autoalloc", name .. " was allocated to " .. team)
		ctf.join(name, team)
	end
end)

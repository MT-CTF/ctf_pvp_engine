-- Get or add a team
function ctf.team(name)
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

		ctf.needs_save = true

		return ctf.teams[name.name]
	else
		if not ctf.teams[name] then
			ctf.warning("team", "'" .. name.."' does not exist!")
		end
		return ctf.teams[name]
	end
end

function ctf.remove_team(name)
	local team = ctf.team(name)
	if team then
		for username, player in pairs(team.players) do
			player.team = nil
		end
		for i = 1, #team.flags do
			team.flags[i].team = nil
		end
		ctf.teams[name] = nil
	end
end

function ctf.list_teams(name)
	minetest.chat_send_player(name, "Teams:")
	for tname, team in pairs(ctf.teams) do
		if team and team.players then
			local details = ""

			local numPlayers = ctf.count_players_in_team(tname)
			details = numPlayers .. " members"

			if team.flags then
				local numFlags = 0
				for flagid, flag in pairs(team.flags) do
					numFlags = numFlags + 1
				end
				details = details .. ", " .. numFlags .. " flags"
			end

			minetest.chat_send_player(name, ">> " .. tname ..
					" (" .. details .. ")")
		end
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
		ctf.list_teams(name)
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
		ctf.needs_save = true

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
	ctf.needs_save = true

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

-- updates the spawn position for a team
function ctf.get_spawn(team)
	if ctf.team(team) and ctf.team(team).spawn then
		return ctf.team(team).spawn
	else
		return nil
	end
end

minetest.register_on_respawnplayer(function(player)
	if not player then
		return false
	end

	local name = player:get_player_name()
	local team = ctf.player(name).team

	if ctf.team(team) then
		local spawn = ctf.get_spawn(team)
		player:moveto(spawn, false)
		return true
	else
		return false
	end
end)

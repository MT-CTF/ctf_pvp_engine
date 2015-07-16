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
		local team = ctf.teams[name]
		if team then
			if not team.data or not team.players then
				ctf.warning("team", "Assertion failed, data{} or players{} not " ..
						"found in team{}")
			end
			return team
		else
			if name and name:trim() ~= "" then
				ctf.warning("team", dump(name) .. " does not exist!")
			end
			return nil
		end
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
		return true
	else
		return false
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
	if not name then
		ctf.error("team", "Can't create a blank player")
		ctf.log("team", debug.traceback())
	end
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

function ctf.remove_player(name)
	ctf.log("team", "Removing player ".. dump(name))
	local player = ctf.players[name]
	if player then
		local team = ctf.team(player.team)
		if team then
			team.players[name] = nil
		end
		ctf.players[name] = nil
		return true
	else
		return false
	end
end

-- Player joins team
-- Called by /join, /team join or auto allocate.
function ctf.join(name, team, force, by)
	if not name or name == "" or not team or team == "" then
		ctf.log("team", "Missing parameters to ctf.join")
		return false
	end

	local player = ctf.player(name)

	if not force and not ctf.setting("players_can_change_team")
			and player.team and ctf.team(player.team) then
		if by then
			if by == name then
				ctf.action("teams", name .. " attempted to change to " .. team)
				minetest.chat_send_player(by, "You are not allowed to switch teams, traitor!")
			else
				ctf.action("teams", by .. " attempted to change " .. name .. " to " .. team)
				minetest.chat_send_player(by, "Failed to add " .. name .. " to " .. team ..
						" as players_can_change_team = false")
			end
		else
			ctf.log("teams", "failed to add " .. name .. " to " .. team ..
					" as players_can_change_team = false")
		end
		return false
	end

	local team_data = ctf.team(team)
	if not team_data then
		if by then
			minetest.chat_send_player(by, "No such team.")
			ctf.list_teams(by)
			if by == name then
				minetest.log("action", by .. " tried to move " .. name .. " to " .. team .. ", which doesn't exist")
			else
				minetest.log("action", name .. " attempted to join " .. team .. ", which doesn't exist")
			end
		else
			ctf.log("teams", "failed to add " .. name .. " to " .. team ..
					" as team does not exist")
		end
		return false
	end

	if player.team then
		local oldteam = ctf.team(player.team)
		if oldteam then
			oldteam.players[player.name] = nil
		end
	end

	player.team = team
	team_data.players[player.name] = player

	minetest.log("action", name .. " joined team " .. team)
	minetest.chat_send_all(name.." has joined team "..team)

	if ctf.setting("hud") then
		ctf.hud.update(minetest.get_player_by_name(name))
	end

	return true
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
		if spawn then
			player:moveto(spawn, false)
			return true
		end
	end

	return false
end)

function ctf.get_territory_owner(pos)
	local largest = nil
	local largest_weight = 0
	for i = 1, #ctf.registered_on_territory_query do
		local team, weight = ctf.registered_on_territory_query[i](pos)
		if team and weight then
			if weight == -1 then
				return team
			end
			if weight > largest_weight then
				largest = team
				largest_weight = weight
			end
		end
	end
	return largest
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

		local spawn = ctf.get_spawn(team)
		if spawn then
			player:moveto(spawn, false)
		end
	end
end)


minetest.register_on_joinplayer(function(player)
	if not ctf.setting("autoalloc_on_joinplayer") then
		return
	end

	local alloc_mode = tonumber(ctf.setting("allocate_mode"))
	if alloc_mode == 0 then
		return
	end
	local name = player:get_player_name()
	local team = ctf.autoalloc(name, alloc_mode)
	if team then
		ctf.log("autoalloc", name .. " was allocated to " .. team)
		ctf.join(name, team)

		local spawn = ctf.get_spawn(team)
		if spawn then
			player:moveto(spawn, false)
		end
	end
end)

minetest.register_on_leaveplayer(function(player)
	if ctf.setting("remove_player_on_leave") then
		ctf.remove_player(player:get_player_name())
	end
end)

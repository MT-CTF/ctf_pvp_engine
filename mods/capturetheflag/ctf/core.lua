function cf.init()
	print("[CaptureTheFlag] Initialising...")

	-- Set up structures
	cf._defsettings = {}
	cf.teams = {}
	cf.players = {}
	cf.claimed = {}
	cf.diplo = {diplo = {}}

	-- Settings: Feature enabling
	cf._set("node_ownership",true)
	cf._set("multiple_flags",true)
	cf._set("flag_capture_take",false) -- whether flags need to be taken to home flag when captured
	cf._set("gui",true) -- whether GUIs are used
	cf._set("team_gui",true) -- GUI on /team is used
	cf._set("flag_teleport_gui",true) -- flag tab in /team
	cf._set("spawn_in_flag_teleport_gui",false) -- show spawn in the flag teleport team gui
	cf._set("news_gui",true) -- news tab in /team
	cf._set("diplomacy",true)
	cf._set("flag_names",true) -- can flags be named
	cf._set("team_channel",true) -- do teams have their own chat channel
	cf._set("global_channel",true) -- Can players chat with other teams on /all. If team_channel is false, this does nothing.
	cf._set("players_can_change_team",true)
	
	-- Settings: Teams
	--cf._set("allocate_mode",0) -- (COMING SOON):how are players allocated to teams?
	cf._set("default_diplo_state","war") -- what is the default diplomatic state? (war/peace/alliance)
	--cf._setb("delete_teams",false) -- (COMING SOON):should teams be deleted when they are defeated?

	-- Settings: Misc
	--cf._set("on_game_end",0) -- (COMING SOON):what happens when the game ends?
	cf._set("flag_protect_distance",25) -- how far do flags protect?
	cf._set("team_gui_initial","news") -- [news/flags/diplo/admin] - the starting tab

	local file = io.open(minetest.get_worldpath().."/ctf.txt", "r")
	if file then
		local table = minetest.deserialize(file:read("*all"))
		if type(table) == "table" then
			cf.teams = table.teams
			cf.players = table.players
			cf.diplo.diplo = table.diplo
			return
		end
	end
end

-- Set settings
function cf._set(setting,default)
	cf._defsettings[setting] = default
end

function cf.setting(name)
	if minetest.setting_get("ctf_"..name) then
		return minetest.setting_get("ctf_"..name)
	elseif cf._defsettings[name] ~= nil then
		return cf._defsettings[name]
	else
		print("[CaptureTheFlag] Setting "..name.." not found!")
		return nil
	end
end

-- Save game
function cf.save()
	print("[CaptureTheFlag] Saving data...")
	local file = io.open(minetest.get_worldpath().."/ctf.txt", "w")
	if file then
		file:write(minetest.serialize({
			teams = cf.teams,
			players = cf.players,
			diplo = cf.diplo.diplo
		}))
		file:close()
	end
end

-- Get or add a team
function cf.team(name) -- get or add a team
	if type(name) == "table" then
		if not name.add_team then
			error("Invalid table given to cf.team")
			return
		end

		print("Defining team "..name.name)

		cf.teams[name.name]={
			data = name,
			spawn=nil,
			players={},
			flags = {}
		}
		
		cf.save()
		
		return cf.teams[name.name]
	else
		return cf.teams[name]
	end
end

-- get a player
function cf.player(name) 
	return cf.players[name]
end

-- Player joins team
function cf.join(name, team, force)
	if not name or name == "" or not team or team == "" then
		return false
	end

	local player = cf.player(name)
		
	if not player then
		player = {name = name}
	end
	
	if not force and not cf.setting("players_can_change_team") and (not player.team or player.team == "") then
		minetest.chat_send_player(name, "You are not allowed to switch teams, traitor!")
		return false
	end

	if cf.add_user(team, player) == true then
		minetest.chat_send_all(name.." has joined team "..team)
		return true
	end
	return false
end

-- Add a player to a team in data structures
function cf.add_user(team, user)
	local _team = cf.team(team)
	local _user = cf.player(user.name)
	if _team and user and user.name then
		if _user and _user.team and cf.team(_user.team) then
			cf.teams[_user.team].players[user.name] = nil
		end

		user.team = team
		user.auth = false
		_team.players[user.name]=user
		cf.players[user.name] = user
		cf.save()

		return true
	else
		return false
	end
end

-- Cleans up the player lists
function cf.clean_player_lists()
	for _, str in pairs(cf.players) do
		if str and str.team and cf.teams[str.team] then
			print("Adding player "..str.name.." to team "..str.team)
			cf.teams[str.team].players[str.name] = str
		else
			print("Skipping player "..str.name)
		end
	end
end

-- Get info for cf.claimed
function cf.collect_claimed()
	cf.claimed = {}
	for _, team in pairs(cf.teams) do
		for i = 1, #team.flags do
			if team.flags[i].claimed then
				table.insert(cf.claimed, team.flags[i])
			end
		end
	end
end

-- Sees if the player can change stuff in a team
function cf.can_mod(player,team)
	local privs = minetest.get_player_privs(player)
	
	if privs then
		if privs.team == true then
		 	return true
		end
	end

	if player and cf.teams[team] and cf.teams[team].players and cf.teams[team].players[player] then
		if cf.teams[team].players[player].auth == true then
			return true
		end
	end
	return false
end

-- post a message to a team board
function cf.post(team,msg)
	if not cf.team(team) then
		return false
	end

	if not cf.team(team).log then
		cf.team(team).log = {}
	end

	table.insert(cf.team(team).log,1,msg)
	cf.save()

	return true
end

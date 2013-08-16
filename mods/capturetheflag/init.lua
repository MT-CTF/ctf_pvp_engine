-- CAPTURE THE FLAG
--	by Andrew "rubenwardy" Ward
-----------------------------------------
cf = {}

-- init game
function cf.init()
	print("[CaptureTheFlag] Initialising...")

	-- Set up structures
	cf.settings = {}
	cf.teams = {}
	cf.players = {}
	cf.diplo.diplo = {}

	-- Settings: Feature enabling
	cf._setb("node_ownership",true)
	cf._setb("multiple_flags",true)
	cf._setb("gui",true)
	cf._setb("team_gui",true)
	cf._setb("flag_names",true) -- can flags be named
	cf._setb("team_channel",true) -- do teams have their own chat channel
	cf._setb("global_channel",true) -- Can players chat with other teams on /all. If team_channel is false, this does nothing.

	-- Settings: Teams
	cf._set("allocate_mode",0) -- how are players allocated to teams?
	cf._set("default_diplo_state","war") -- what is the default diplomatic state? (war/peace/alliance)
	cf._setb("delete_teams",false) -- should teams be deleted when they are defeated?

	-- Settings: Misc
	cf._set("on_game_end",0) -- what happens when the game ends?
	cf._set("flag_protect_distance",25) -- how far do flags protect?

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
	if minetest.setting_get("ctf_"..setting)~=nil and minetest.setting_get("ctf_"..setting)~="" then
		print("Setting: "..setting.." has been set from config")
		cf.settings[setting] = minetest.setting_get("ctf_"..setting)
	else
		print("Setting: "..setting.." has been set from default")
		cf.settings[setting] = default
	end
end

function cf._setb(setting,default)
	if minetest.setting_get("ctf_"..setting)~=nil and minetest.setting_get("ctf_"..setting)~=""  then
		cf.settings[setting] = minetest.setting_getbool("ctf_"..setting)
	else
		cf.settings[setting] = default
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

-- add a user to a team
function cf.add_user(team,user)
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

-- Cleans up the flag lists
function cf.clean_flags()
	for _, str in pairs(cf.teams) do
		cf.area.asset_flags(str.data.name)
	end
end

-- Sees if the player can change stuff in a team
function cf.can_mod(player,team)
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

-- diplo states: war, peace, alliance
cf.diplo = {}

function cf.diplo.get(one,two)
	if not cf.diplo.diplo then
        	return cf.settings.default_diplo_state
	end

	for i=1,#cf.diplo.diplo do
		local dip = cf.diplo.diplo[i]
		if (dip.one == one and dip.two == two) or (dip.one == two and dip.two == one) then
			return dip.state
		end
	end

	return cf.settings.default_diplo_state
end

function cf.diplo.set(one,two,state)
	if cf.diplo.diplo then
		for i=1,#cf.diplo.diplo do
			local dip = cf.diplo.diplo[i]
			if (dip.one == one and dip.two == two) or (dip.one == two and dip.two == one) then
				dip.state = state
				return
			end
		end
	end
	
	table.insert(cf.diplo.diplo,{one=one,two=two,state=state})
	return
end

-- Vector stuff
v3={}
function v3.distance(v, w)
    return math.sqrt(
        math.pow(v.x - w.x, 2) +
        math.pow(v.y - w.y, 2) +
        math.pow(v.z - w.z, 2)
    )
end
function v3.get_direction(pos1,pos2)

	local x_raw = pos2.x -pos1.x
	local y_raw = pos2.y -pos1.y
	local z_raw = pos2.z -pos1.z


	local x_abs = math.abs(x_raw)
	local y_abs = math.abs(y_raw)
	local z_abs = math.abs(z_raw)

	if 	x_abs >= y_abs and
		x_abs >= z_abs then

		y_raw = y_raw * (1/x_abs)
		z_raw = z_raw * (1/x_abs)

		x_raw = x_raw/x_abs

	end

	if 	y_abs >= x_abs and
		y_abs >= z_abs then


		x_raw = x_raw * (1/y_abs)
		z_raw = z_raw * (1/y_abs)

		y_raw = y_raw/y_abs

	end

	if 	z_abs >= y_abs and
		z_abs >= x_abs then

		x_raw = x_raw * (1/z_abs)
		y_raw = y_raw * (1/z_abs)

		z_raw = z_raw/z_abs

	end

	return {x=x_raw,y=y_raw,z=z_raw}
end

-- Load the core
cf.init()
cf.clean_player_lists()

-- Load Modules
dofile(minetest.get_modpath("capturetheflag").."/area.lua")
dofile(minetest.get_modpath("capturetheflag").."/gui.lua")
dofile(minetest.get_modpath("capturetheflag").."/cli.lua")
dofile(minetest.get_modpath("capturetheflag").."/flag.lua")
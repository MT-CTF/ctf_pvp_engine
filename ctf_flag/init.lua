-- Initialise
ctf.register_on_init(function()
	ctf.log("flag", "Initialising...")
	ctf._set("flag.allow_multiple",        true)
	ctf._set("flag.capture_take",          false)
	ctf._set("flag.names",                 true)
	ctf._set("flag.waypoints",             true)
	ctf._set("flag.protect_distance",      25)
	ctf._set("flag.capture_mode",          "take")
	ctf._set("gui.team.teleport_to_flag",  true)
	ctf._set("gui.team.teleport_to_spawn", false)
end)

ctf.register_on_new_team(function(team)
	team.flags = {}
end)

ctf.register_on_territory_query(function(pos)
	local closest = nil
	local closest_team = nil
	local closest_distSQ = 1000000
	local pd = ctf.setting("flag.protect_distance")
	local pdSQ = pd * pd

	for tname, team in pairs(ctf.teams) do
		for i = 1, #team.flags do
			local distSQ = vector.distanceSQ(pos, team.flags[i])
			if distSQ < pdSQ and distSQ < closest_distSQ then
				closest = team.flags[i]
				closest_team = tname
				closest_distSQ = distSQ
			end
		end
	end

	return closest_team, closest_distSQ
end)

function ctf.get_spawn(team)
	if not ctf.team(team) then
		return nil
	end

	if ctf.team(team).spawn then
		return ctf.team(team).spawn
	end

	-- Get spawn from first flag
	ctf_flag.assert_flags(team)
	if #ctf.team(team).flags > 0 then
		return ctf.team(team).flags[1]
	else
		return nil
	end
end

dofile(minetest.get_modpath("ctf_flag") .. "/hud.lua")
dofile(minetest.get_modpath("ctf_flag") .. "/gui.lua")
dofile(minetest.get_modpath("ctf_flag") .. "/flag_func.lua")
dofile(minetest.get_modpath("ctf_flag") .. "/api.lua")
dofile(minetest.get_modpath("ctf_flag") .. "/flags.lua")

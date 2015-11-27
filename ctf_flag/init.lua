-- Initialise
ctf.register_on_init(function()
	ctf.log("flag", "Initialising...")
	ctf._set("flag.allow_multiple",        true)
	ctf._set("flag.capture_take",          false)
	ctf._set("flag.names",                 true)
	ctf._set("flag.waypoints",             true)
	ctf._set("flag.protect_distance",      25)
	ctf._set("flag.nobuild_radius",        3)
	ctf._set("flag.capture_mode",          "take")
	ctf._set("gui.team.teleport_to_flag",  true)
	ctf._set("gui.team.teleport_to_spawn", false)
end)

dofile(minetest.get_modpath("ctf_flag") .. "/hud.lua")
dofile(minetest.get_modpath("ctf_flag") .. "/gui.lua")
dofile(minetest.get_modpath("ctf_flag") .. "/flag_func.lua")
dofile(minetest.get_modpath("ctf_flag") .. "/api.lua")
dofile(minetest.get_modpath("ctf_flag") .. "/flags.lua")

ctf.register_on_new_team(function(team)
	team.flags = {}
end)

function ctf_flag.get_nearest(pos)
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
end

ctf.register_on_territory_query(ctf_flag.get_nearest)

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

-- Add minimum build range
local old_is_protected = minetest.is_protected
local r = ctf.setting("flag.nobuild_radius")
local rs = r * r
function minetest.is_protected(pos, name)
	if rs == 0 then
		return old_is_protected(pos, name)
	end

	local tname, distsq = ctf_flag.get_nearest(pos)
	if distsq < rs then
		minetest.chat_send_player(name,
			"Too close to the flag to build! You need to be at least " .. r .. " nodes away.")
		minetest.chat_send_player(name,
			"This is to stop new or respawning players from being trapped.")
		return true
	else
		return old_is_protected(pos, name)
	end
end

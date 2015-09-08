-- Initialise
ctf.register_on_init(function()
	ctf.log("flag", "Initialising...")
	ctf._set("flag.allow_multiple",        true)
	ctf._set("flag.capture_take",          false)
	ctf._set("flag.names",                 true)
	ctf._set("flag.protect_distance",      25)
	ctf._set("gui.team.teleport_to_flag",  true)
	ctf._set("gui.team.teleport_to_spawn", false)
	ctf._set("flag.capture_mode",          "take")
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

dofile(minetest.get_modpath("ctf_flag") .. "/gui.lua")
dofile(minetest.get_modpath("ctf_flag") .. "/flag_func.lua")

ctf_flag.registered_on_capture = {}
function ctf_flag.register_on_capture(func)
	if ctf._mt_loaded then
		error("You can't register callbacks at game time!")
	end
	table.insert(ctf_flag.registered_on_capture, func)
end

ctf_flag.registered_on_pick_up = {}
function ctf_flag.register_on_pick_up(func)
	if ctf._mt_loaded then
		error("You can't register callbacks at game time!")
	end
	table.insert(ctf_flag.registered_on_pick_up, func)
end

function ctf_flag.collect_claimed()
	local claimed = {}
	for _, team in pairs(ctf.teams) do
		for i = 1, #team.flags do
			if team.flags[i].claimed then
				table.insert(claimed, team.flags[i])
			end
		end
	end
	return claimed
end

function ctf_flag.player_drop_flag(name)
	if not name then
		return
	end

	local claimed = ctf_flag.collect_claimed()
	for i = 1, #claimed do
		local flag = claimed[i]
		if flag.claimed.player == name then
			flag.claimed = nil

			local flag_name = ""
			if flag.name then
				flag_name = flag.name .. " "
			end
			flag_name = flag.team .. "'s " .. flag_name .. "flag"

			ctf.action("flag", name .. " dropped " .. flag_name)
			minetest.chat_send_all(flag_name.." has returned.")
		end
	end
end

-- add a flag to a team
function ctf_flag.add(team, pos)
	if not team or team == "" then
		return
	end

	ctf.log("flag", "Adding flag to " .. team .. " at (" .. pos.x ..
			", " .. pos.y .. ", " .. pos.z .. ")")

	if not ctf.team(team).flags then
		ctf.team(team).flags = {}
	end

	pos.team = team
	table.insert(ctf.team(team).flags,pos)
	ctf.needs_save = true
end

function ctf_flag.update(pos)
	if minetest.get_node(pos).name ~= "ctf_flag:flag" then
		return
	end

	local top = {x=pos.x,y=pos.y+1,z=pos.z}
	local flagmeta = minetest.get_meta(pos)

	if not flagmeta then
		return
	end

	local flag_team_data = ctf_flag.get(pos)
	if not flag_team_data or not ctf.team(flag_team_data.team)then
		ctf.log("flag", "Flag does not exist! Deleting nodes. "..dump(pos))
		minetest.set_node(pos,{name="air"})
		minetest.set_node(top,{name="air"})
		return
	end
	local topmeta = minetest.get_meta(top)
	local flag_name = flag_team_data.name
	if flag_name and flag_name ~= "" then
		flagmeta:set_string("infotext", flag_name.." - "..flag_team_data.team)
	else
		flagmeta:set_string("infotext", flag_team_data.team.."'s flag")
	end

	if not ctf.team(flag_team_data.team).data.color then
		ctf.team(flag_team_data.team).data.color = "red"
		ctf.needs_save = true
	end

	if flag_team_data.claimed then
		minetest.set_node(top,{name="ctf_flag:flag_captured_top"})
	else
		minetest.set_node(top,{name="ctf_flag:flag_top_"..ctf.team(flag_team_data.team).data.color})
	end

	topmeta = minetest.get_meta(top)
	if flag_name and flag_name ~= "" then
		topmeta:set_string("infotext", flag_name.." - "..flag_team_data.team)
	else
		topmeta:set_string("infotext", flag_team_data.team.."'s flag")
	end
end

-- get a flag from a team
function ctf_flag.get(pos)
	if not pos then
		return
	end

	local result = nil
	for _, team in pairs(ctf.teams) do
		for i = 1, #team.flags do
			if (
				team.flags[i].x == pos.x and
				team.flags[i].y == pos.y and
				team.flags[i].z == pos.z
			) then
				if result then
					minetest.chat_send_all("[CTF ERROR] Multiple teams have same flag. Please report this to the server operator / admin")
					print("CTF ERROR DATA")
					print("Multiple teams have same flag.")
					print("This is a sign of ctf.txt corruption.")
					print("----------------")
					print(dump(result))
					print(dump(team.flags[i]))
					print("----------------")
				else
					result = team.flags[i]
				end
			end
		end
	end
	return result
end

-- delete a flag from a team
function ctf_flag.delete(team, pos)
	if not team or team == "" then
		return
	end

	ctf.log("flag", "Deleting flag from " .. team .. " at (" .. pos.x ..
			", " .. pos.y .. ", " .. pos.z .. ")")

	for i = 1, #ctf.team(team).flags do
		if (
			ctf.team(team).flags[i].x == pos.x and
			ctf.team(team).flags[i].y == pos.y and
			ctf.team(team).flags[i].z == pos.z
		) then
			table.remove(ctf.team(team).flags,i)
			return
		end
	end
end

function ctf_flag.assert_flags()
	for tname, team in pairs(ctf.teams) do
		ctf_flag.assert_flags_team(tname)
	end
end

function ctf_flag.assert_flags_team(tname)
	local team = ctf.team(tname)
	if not tname or not team then
		return false
	end

	for i=1, #team.flags do
		local flag = team.flags[i]
		minetest.get_voxel_manip(flag, { x = flag.x + 1, y = flag.y + 1, z = flag.z + 1})
		local nodename = minetest.get_node(flag).name
		if nodename ~= "ctf_flag:flag" then
			ctf.log("flag", tname .. " has wrong node at flag position, " .. nodename .. ", correcting...")
			minetest.set_node(flag, { name = "ctf_flag:flag"})
		end
	end
end

-- The flag
minetest.register_node("ctf_flag:flag", {
	description = "Flag",
	drawtype="nodebox",
	paramtype = "light",
	walkable = false,
	tiles = {
		"default_wood.png",
		"default_wood.png",
		"default_wood.png",
		"default_wood.png",
		"default_wood.png",
		"default_wood.png"
	},
	node_box = {
		type = "fixed",
		fixed = {
			{0.250000,-0.500000,0.000000,0.312500,0.500000,0.062500}
		}
	},
	groups = {immortal=1,is_flag=1,flag_bottom=1},
	on_punch = ctf_flag.on_punch,
	on_rightclick = ctf_flag.on_rightclick,
	on_construct = ctf_flag.on_construct,
	after_place_node = ctf_flag.after_place_node
})

for color, _ in pairs(ctf.flag_colors) do
	minetest.register_node("ctf_flag:flag_top_"..color,{
		description = "You are not meant to have this! - flag top",
		drawtype="nodebox",
		paramtype = "light",
		walkable = false,
		tiles = {
			"default_wood.png",
			"default_wood.png",
			"default_wood.png",
			"default_wood.png",
			"flag_"..color.."2.png",
			"flag_"..color..".png"
		},
		node_box = {
			type = "fixed",
			fixed = {
				{0.250000,-0.500000,0.000000,0.312500,0.500000,0.062500},
				{-0.5,0,0.000000,0.250000,0.500000,0.062500}
			}
		},
		groups = {immortal=1,is_flag=1,flag_top=1,not_in_creative_inventory=1},
		on_punch = ctf_flag.on_punch_top,
		on_rightclick = ctf_flag.on_rightclick_top
	})
end

minetest.register_node("ctf_flag:flag_captured_top",{
	description = "You are not meant to have this! - flag captured",
	drawtype = "nodebox",
	paramtype = "light",
	walkable = false,
	tiles = {
		"default_wood.png",
		"default_wood.png",
		"default_wood.png",
		"default_wood.png",
		"default_wood.png",
		"default_wood.png"
	},
	node_box = {
		type = "fixed",
		fixed = {
			{0.250000,-0.500000,0.000000,0.312500,0.500000,0.062500}
		}
	},
	groups = {immortal=1,is_flag=1,flag_top=1,not_in_creative_inventory=1},
	on_punch = ctf_flag.on_punch_top,
	on_rightclick = ctf_flag.on_rightclick_top
})

minetest.register_abm({
	nodenames = {"group:flag_bottom"},
	inteval = 5,
	chance = 1,
	action = ctf_flag.update
})

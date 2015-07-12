-- Initialise
function init()
	ctf._set("flag.allow_multiple",        true)
	ctf._set("flag.capture_take",          false)
	ctf._set("flag.names",                 true)
	ctf._set("flag.protect_distance",      25)
end
init()
ctf.register_on_new_team(function(team)
	team.flags = {}
end)
ctf_flag = {}
dofile(minetest.get_modpath("ctf_flag") .. "/gui.lua")
dofile(minetest.get_modpath("ctf_flag") .. "/flag_func.lua")

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
ctf.flag_colors = {
	red   = "0xFF0000",
	green = "0x00FF00",
	blue  = "0x0000FF"
}

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
	action = function(pos)
		local top = {x=pos.x,y=pos.y+1,z=pos.z}
		local flagmeta = minetest.env:get_meta(pos)

		if not flagmeta then
			return
		end

		local flag_team_data = ctf.area.get_flag(pos)
		if not flag_team_data or not ctf.team(flag_team_data.team)then
			ctf.log("flag", "Flag does not exist! Deleting nodes. "..dump(pos))
			minetest.env:set_node(pos,{name="air"})
			minetest.env:set_node(top,{name="air"})
			return
		end
		local topmeta = minetest.env:get_meta(top)
		local flag_name = flag_team_data.name
		if flag_name and flag_name ~= "" then
			flagmeta:set_string("infotext", flag_name.." - "..flag_team_data.team)
		else
			flagmeta:set_string("infotext", flag_team_data.team.."'s flag")
		end

		if not ctf.team(flag_team_data.team).data.color then
			ctf.team(flag_team_data.team).data.color = "red"
			ctf.save()
		end

		if flag_team_data.claimed then
			minetest.env:set_node(top,{name="ctf_flag:flag_captured_top"})
		else
			minetest.env:set_node(top,{name="ctf_flag:flag_top_"..ctf.team(flag_team_data.team).data.color})
		end

		topmeta = minetest.env:get_meta(top)
		if flag_name and flag_name ~= "" then
			topmeta:set_string("infotext", flag_name.." - "..flag_team_data.team)
		else
			topmeta:set_string("infotext", flag_team_data.team.."'s flag")
		end
	end
})

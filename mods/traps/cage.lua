-- Rubenwardy's Trap Mod
--
--
--
--
-- Cage Trap


minetest.register_node("traps:cage",{
	tile_images = {"traps_grass.png", "default_dirt.png",
			"default_grass_side.png", "default_grass_side.png",
			"default_grass_side.png", "default_grass_side.png"},
	inventory_image = minetest.inventorycube("traps_grass.png",
			"default_grass_side.png", "default_grass_side.png"),
	dug_item = '', -- Get nothing
	groups={immortal},
	description = "Cage Trap",
})

minetest.register_node("traps:uncage",{
	tile_images = {"traps_uncage.png"},
	inventory_image = minetest.inventorycube("traps_uncage.png",
			"traps_uncage.png", "traps_uncage.png"),
	dug_item = '', -- Get nothing
	groups={immortal},
	description = "Cage Trap Release",
})

minetest.register_node("traps:cage_glass", {
	description = "Cage glass",
	drawtype = "glasslike",
	tiles = {"default_glass.png"},
	inventory_image = minetest.inventorycube("default_glass.png"),
	paramtype = "light",
	sunlight_propagates = true,
	groups = {immortl},
	sounds = default.node_sound_glass_defaults(),
})

local block_to_place="traps:cage_glass"

minetest.register_abm(
	{nodenames = {"traps:cage"},
	interval = 0.2,
	chance = 1,
	action = function(pos, node, active_object_count, active_object_count_wider)
		local objs = minetest.env:get_objects_inside_radius(pos, 1)
		for k, obj in pairs(objs) do
			print("HIT!")
			--local objpos=obj:getpos()

			local tmp

			minetest.env:add_node(pos,{name=block_to_place})

			--Left
			print("Left")
			tmp={x=(pos.x+1),y=(pos.y+1),z=(pos.z)}
			minetest.env:add_node(tmp,{name=block_to_place})

			--Right
			print("right")
			tmp={x=(pos.x-1),y=(pos.y+1),z=(pos.z)}
			minetest.env:add_node(tmp,{name=block_to_place})

			--Front
			print("front")
			tmp={x=(pos.x),y=(pos.y+1),z=(pos.z+1)}
			minetest.env:add_node(tmp,{name=block_to_place})

			--Back
			print("back")
			tmp={x=(pos.x),y=(pos.y+1),z=(pos.z-1)}
			minetest.env:add_node(tmp,{name=block_to_place})

			--Left
			print("Left")
			tmp={x=(pos.x+1),y=(pos.y+2),z=(pos.z)}
			minetest.env:add_node(tmp,{name=block_to_place})

			--Right
			print("right")
			tmp={x=(pos.x-1),y=(pos.y+2),z=(pos.z)}
			minetest.env:add_node(tmp,{name=block_to_place})

			--Front
			print("front")
			tmp={x=(pos.x),y=(pos.y+2),z=(pos.z+1)}
			minetest.env:add_node(tmp,{name=block_to_place})

			--Back
			print("back")
			tmp={x=(pos.x),y=(pos.y+2),z=(pos.z-1)}
			minetest.env:add_node(tmp,{name=block_to_place})

			--Top
			print("top")
			tmp={x=(pos.x),y=(pos.y+3),z=(pos.z)}
			minetest.env:add_node(tmp,{name=block_to_place})

			--Release	
			print("release")
			tmp={x=(pos.x+1),y=(pos.y),z=(pos.z+1)}
			minetest.env:add_node(tmp,{name="traps:uncage"})

			--if objpos.y>pos.y-1 and objpos.y<pos.y then
			--	local tmp
			--	minetest.env:add_node(tmp,{name=block_to_place})
			--end
		end	
	end,
})

-- Rubenwardy's Trap Mod
--
--
--
--
-- Decage

local air_to_place="air"

minetest.register_abm(
	{nodenames = {"traps:uncage"},
	interval = 0.2,
	chance = 1,
	action = function(pos, node, active_object_count, active_object_count_wider)
		local objs = minetest.env:get_objects_inside_radius(pos, 1)
		for k, obj in pairs(objs) do
			print("HIT!")
			--local objpos=obj:getpos()

			local tmp

			minetest.env:add_node(pos,{name="default:dirt"})

			--Left
			print("Left")
			tmp={x=(pos.x),y=(pos.y+1),z=(pos.z-1)}
			minetest.env:add_node(tmp,{name=air_to_place})

			--Right
			print("right")
			tmp={x=(pos.x-2),y=(pos.y+1),z=(pos.z-1)}
			minetest.env:add_node(tmp,{name=air_to_place})

			--Front
			print("front")
			tmp={x=(pos.x-1),y=(pos.y+1),z=(pos.z)}
			minetest.env:add_node(tmp,{name=air_to_place})

			--Back
			print("back")
			tmp={x=(pos.x-1),y=(pos.y+1),z=(pos.z-2)}
			minetest.env:add_node(tmp,{name=air_to_place})

			--Left
			print("Left")
			tmp={x=(pos.x),y=(pos.y+2),z=(pos.z-1)}
			minetest.env:add_node(tmp,{name=air_to_place})

			--Right
			print("right")
			tmp={x=(pos.x-2),y=(pos.y+2),z=(pos.z-1)}
			minetest.env:add_node(tmp,{name=air_to_place})

			--Front
			print("front")
			tmp={x=(pos.x-1),y=(pos.y+2),z=(pos.z)}
			minetest.env:add_node(tmp,{name=air_to_place})

			--Back
			print("back")
			tmp={x=(pos.x-1),y=(pos.y+2),z=(pos.z-2)}
			minetest.env:add_node(tmp,{name=air_to_place})

			--Top
			print("top")
			tmp={x=(pos.x-1),y=(pos.y+3),z=(pos.z-1)}
			minetest.env:add_node(tmp,{name=air_to_place})

			-- Floor
			print("release")
			tmp={x=(pos.x-1),y=(pos.y),z=(pos.z-1)}
			minetest.env:add_node(tmp,{name="default:dirt"})
		
		end	
	end,
})

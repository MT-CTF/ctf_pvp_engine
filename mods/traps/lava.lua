-- Rubenwardy's Trap Mod
--
--
--
--
-- Cage Trap


minetest.register_node("traps:lava",{
	tile_images = {"traps_grass.png", "default_dirt.png",
			"default_grass_side.png", "default_grass_side.png",
			"default_grass_side.png", "default_grass_side.png"},
	inventory_image = minetest.inventorycube("traps_grass.png",
			"default_grass_side.png", "default_grass_side.png"),
	dug_item = '', -- Get nothing
	groups={immortal},
	description = "Lava Drop Trap",
})

local block_to_place="default:lava_source"
local hi=5 --How high the lava is

minetest.register_abm(
	{nodenames = {"traps:lava"},
	interval = 0.2,
	chance = 1,
	action = function(pos, node, active_object_count, active_object_count_wider)
		local objs = minetest.env:get_objects_inside_radius(pos, 1)
		for k, obj in pairs(objs) do
			print("HIT!")
			--local objpos=obj:getpos()

			local tmp

			minetest.env:add_node(pos,{name="default:dirt"})

			--Left side pit
			tmp={x=pos.x-2,y=pos.y,z=pos.z-2}
			minetest.env:add_node(tmp,{name="air"})

			tmp={x=pos.x-2,y=pos.y,z=pos.z-1}
			minetest.env:add_node(tmp,{name="air"})

			tmp={x=pos.x-2,y=pos.y,z=pos.z}
			minetest.env:add_node(tmp,{name="air"})

			tmp={x=pos.x-2,y=pos.y,z=pos.z+1}
			minetest.env:add_node(tmp,{name="air"})

			tmp={x=pos.x-2,y=pos.y,z=pos.z+2}
			minetest.env:add_node(tmp,{name="air"})

			--Right side pit
			tmp={x=pos.x+2,y=pos.y,z=pos.z-2}
			minetest.env:add_node(tmp,{name="air"})

			tmp={x=pos.x+2,y=pos.y,z=pos.z-1}
			minetest.env:add_node(tmp,{name="air"})

			tmp={x=pos.x+2,y=pos.y,z=pos.z}
			minetest.env:add_node(tmp,{name="air"})

			tmp={x=pos.x+2,y=pos.y,z=pos.z+1}
			minetest.env:add_node(tmp,{name="air"})

			tmp={x=pos.x+2,y=pos.y,z=pos.z+2}
			minetest.env:add_node(tmp,{name="air"})

			--front side pit
			tmp={x=pos.x-1,y=pos.y,z=pos.z-2}
			minetest.env:add_node(tmp,{name="air"})

			tmp={x=pos.x,y=pos.y,z=pos.z-2}
			minetest.env:add_node(tmp,{name="air"})

			tmp={x=pos.x+1,y=pos.y,z=pos.z-2}
			minetest.env:add_node(tmp,{name="air"})

			--back side pit
			tmp={x=pos.x-1,y=pos.y,z=pos.z+2}
			minetest.env:add_node(tmp,{name="air"})

			tmp={x=pos.x,y=pos.y,z=pos.z+2}
			minetest.env:add_node(tmp,{name="air"})

			tmp={x=pos.x+1,y=pos.y,z=pos.z+2}
			minetest.env:add_node(tmp,{name="air"})

			-- PLACE LAVA
			-- 
			-- 
			
			--Left side lava
			tmp={x=pos.x-2,y=pos.y+hi,z=pos.z-2}
			minetest.env:add_node(tmp,{name=block_to_place})

			tmp={x=pos.x-2,y=pos.y+hi,z=pos.z-1}
			minetest.env:add_node(tmp,{name=block_to_place})

			tmp={x=pos.x-2,y=pos.y+hi,z=pos.z}
			minetest.env:add_node(tmp,{name=block_to_place})

			tmp={x=pos.x-2,y=pos.y+hi,z=pos.z+1}
			minetest.env:add_node(tmp,{name=block_to_place})

			tmp={x=pos.x-2,y=pos.y+hi,z=pos.z+2}
			minetest.env:add_node(tmp,{name=block_to_place})

			--Right side lava
			tmp={x=pos.x+2,y=pos.y+hi,z=pos.z-2}
			minetest.env:add_node(tmp,{name=block_to_place})

			tmp={x=pos.x+2,y=pos.y+hi,z=pos.z-1}
			minetest.env:add_node(tmp,{name=block_to_place})

			tmp={x=pos.x+2,y=pos.y+hi,z=pos.z}
			minetest.env:add_node(tmp,{name=block_to_place})

			tmp={x=pos.x+2,y=pos.y+hi,z=pos.z+1}
			minetest.env:add_node(tmp,{name=block_to_place})

			tmp={x=pos.x+2,y=pos.y+hi,z=pos.z+2}
			minetest.env:add_node(tmp,{name=block_to_place})

			--front side pit
			tmp={x=pos.x-1,y=pos.y+hi,z=pos.z-2}
			minetest.env:add_node(tmp,{name=block_to_place})

			tmp={x=pos.x,y=pos.y+hi,z=pos.z-2}
			minetest.env:add_node(tmp,{name=block_to_place})

			tmp={x=pos.x+1,y=pos.y+hi,z=pos.z-2}
			minetest.env:add_node(tmp,{name=block_to_place})

			--back side lava
			tmp={x=pos.x-1,y=pos.y+hi,z=pos.z+2}
			minetest.env:add_node(tmp,{name=block_to_place})

			tmp={x=pos.x,y=pos.y+hi,z=pos.z+2}
			minetest.env:add_node(tmp,{name=block_to_place})

			tmp={x=pos.x+1,y=pos.y+hi,z=pos.z+2}
			minetest.env:add_node(tmp,{name=block_to_place})


			--block barrier
			tmp={x=pos.x,y=pos.y+hi-1,z=pos.z}
			minetest.env:add_node(tmp,{name="default:glass"})

			--1
			tmp={x=pos.x+1,y=pos.y+hi-1,z=pos.z+1}
			minetest.env:add_node(tmp,{name="default:glass"})

			tmp={x=pos.x+1,y=pos.y+hi-1,z=pos.z}
			minetest.env:add_node(tmp,{name="default:glass"})

			tmp={x=pos.x+1,y=pos.y+hi-1,z=pos.z-1}
			minetest.env:add_node(tmp,{name="default:glass"})

			--2
			tmp={x=pos.x,y=pos.y+hi-1,z=pos.z-1}
			minetest.env:add_node(tmp,{name="default:glass"})

			tmp={x=pos.x-1,y=pos.y+hi-1,z=pos.z+1}
			minetest.env:add_node(tmp,{name="default:glass"})

			tmp={x=pos.x-1,y=pos.y+hi-1,z=pos.z-1}
			minetest.env:add_node(tmp,{name="default:glass"})

			tmp={x=pos.x,y=pos.y+hi-1,z=pos.z+1}
			minetest.env:add_node(tmp,{name="default:glass"})

			tmp={x=pos.x-1,y=pos.y+hi-1,z=pos.z}
			minetest.env:add_node(tmp,{name="default:glass"})

			
		end	
	end,
})
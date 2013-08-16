function spawn_tnt(pos, entname)
    minetest.sound_play("nuke_ignite", {pos = pos,gain = 1.0,max_hear_distance = 8,})
    return minetest.env:add_entity(pos, entname)
end

function activate_if_tnt(nname, np, tnt_np, tntr)
    if nname == "experimental:tnt" or nname == "traps:mine" or nname == "nuke:mese_tnt" or nname == "nuke:hardcore_iron_tnt" or nname == "nuke:hardcore_mese_tnt" then
        local e = spawn_tnt(np, nname)
        e:setvelocity({x=(np.x - tnt_np.x)*3+(tntr / 4), y=(np.y - tnt_np.y)*3+(tntr / 3), z=(np.z - tnt_np.z)*3+(tntr / 4)})
    end
end

function do_tnt_physics(tnt_np,tntr)
    local objs = minetest.env:get_objects_inside_radius(tnt_np, tntr)
    for k, obj in pairs(objs) do
        local oname = obj:get_entity_name()
        local v = obj:getvelocity()
        local p = obj:getpos()
        if oname == "experimental:tnt" or oname == "traps:mine" or oname == "nuke:mese_tnt" or oname == "nuke:hardcore_iron_tnt" or oname == "nuke:hardcore_mese_tnt" then
            obj:setvelocity({x=(p.x - tnt_np.x) + (tntr / 2) + v.x, y=(p.y - tnt_np.y) + tntr + v.y, z=(p.z - tnt_np.z) + (tntr / 2) + v.z})
        else
            if v ~= nil then
                obj:setvelocity({x=(p.x - tnt_np.x) + (tntr / 4) + v.x, y=(p.y - tnt_np.y) + (tntr / 2) + v.y, z=(p.z - tnt_np.z) + (tntr / 4) + v.z})
            else
                if obj:get_player_name() ~= nil then
                    obj:set_hp(0)
                end
            end
        end
    end
end

minetest.register_node("traps:mine", {
	tile_images = {"traps_grass.png", "default_dirt.png",
			"default_grass_side.png", "default_grass_side.png",
			"default_grass_side.png", "default_grass_side.png"},
	inventory_image = minetest.inventorycube("traps_grass.png",
			"nuke_iron_tnt_side.png", "nuke_iron_tnt_side.png"),
	dug_item = '', -- Get nothing
	material = {
		diggability = "not",
	},
	description = "Minetrap",
})



local IRON_TNT_RANGE = 3
local IRON_TNT = {
	-- Static definition
	physical = true, -- Collides with things
	-- weight = 5,
	collisionbox = {-0.5,-0.5,-0.5, 0.5,0.5,0.5},
	visual = "cube",
	textures = {"nuke_iron_tnt_top.png", "nuke_iron_tnt_bottom.png",
			"nuke_iron_tnt_side.png", "nuke_iron_tnt_side.png",
			"nuke_iron_tnt_side.png", "nuke_iron_tnt_side.png"},
	-- Initial value for our timer
	timer = 0,
	-- Number of punches required to defuse
	health = 1,
	blinktimer = 0,
	blinkstatus = true,
}

minetest.register_abm(
	{nodenames = {"traps:mine"},
	interval = 0.2,
	chance = 1,
	action = function(pos, node, active_object_count, active_object_count_wider)
		local objs = minetest.env:get_objects_inside_radius(pos, 1)
		for k, obj in pairs(objs) do
			print("HIT!")
			
        for x=-IRON_TNT_RANGE,IRON_TNT_RANGE do
        for y=-IRON_TNT_RANGE,IRON_TNT_RANGE do
        for z=-IRON_TNT_RANGE,IRON_TNT_RANGE do
            if x*x+y*y+z*z <= IRON_TNT_RANGE * IRON_TNT_RANGE + IRON_TNT_RANGE then
                local np={x=pos.x+x,y=pos.y+y,z=pos.z+z}
                local n = minetest.env:get_node(np)
                if n.name ~= "air" then
                    minetest.env:remove_node(np)
                end
                --activate_if_tnt(n.name, np, pos, IRON_TNT_RANGE)
            end
        end
        end
        end
if obj:get_player_name() ~= nil then
                    obj:set_hp(obj:get_hp() - 10)
                end
		minetest.env:add_node(pos,{name="air"})
		--self.object:remove()
			--minetest.env:remove_node(pos)
			--spawn_tnt(pos, "nuke:iron_tnt")
			--nodeupdate(pos)
		end	
	end,
})


ARROW_DAMAGE = 2
ARROW_VELOCITY = 2
minetest.register_node("turret:turret", {
	description = "Team Turret",
	tiles = {
		"default_stone.png",
		"default_stone.png",
		"default_stone.png",
		"default_stone.png",
		"default_stone.png",
		"default_stone.png",
	},
	drawtype="nodebox",
	groups={attached_node=1},
	paramtype = "light",
	node_box = {
		type = "fixed",
		fixed = {
			{-0.500000,-0.500000,-0.500000,0.500000,0.000000,0.500000}, --NodeBox 1
			{-0.437500,0.000000,-0.437500,0.431250,0.187500,0.431250}, --NodeBox 2
			{-0.187500,0.187500,-0.187500,0.187500,0.500000,0.187500}, --NodeBox 3
		}
	},
	groups = {cracky=3, stone=1},
	on_construct = function(pos)
		local meta = minetest.env:get_meta(pos)
		meta:set_string("infotext", "Unowned turret")
	end,
	after_place_node = function(pos, placer)
		local meta = minetest.env:get_meta(pos)

		if meta and cf.players and cf.player(placer:get_player_name()) and cf.player(placer:get_player_name()).team then
			local team = cf.player(placer:get_player_name()).team
			meta:set_string("team", team)
			meta:set_string("infotext", "Owned by "..team)
		else
			minetest.env:set_node(pos,{name="air"})
		end
	end
})

minetest.register_abm({
	nodenames = {"turret:turret"},
	interval = 0.25,
	chance = 4,
	action = function(pos, node)
		local meta = minetest.env:get_meta(pos)
		if not meta then
			return
		end

		local team = meta:get_string("team")
		if not team then
			return
		end

		local app = cf.area.get_area(pos)
		if app and app~=team then
			team = app
			meta:set_string("team",team)
			meta:set_string("infotext", "Owned by "..team)
		end
		
		if not team then
			return
		end

		local objects = minetest.env:get_objects_inside_radius(pos, 15)
		for _,obj in ipairs(objects) do
			if (
				obj:is_player() and
				cf.players and
				cf.player(obj:get_player_name()) and
				cf.player(obj:get_player_name()).team ~= team
			)then
				-- Calculate stuff
				local obj_p = obj:getpos()
				local calc = {
					x=obj_p.x - pos.x,
					y=obj_p.y+1 - pos.y,
					z=obj_p.z - pos.z
				}

				-- Create bullet entity
				local bullet=minetest.env:add_entity({x=pos.x,y=pos.y+0.5,z=pos.z}, "turret:arrow_entity")
				
				-- Set velocity
				bullet:setvelocity({x=calc.x * ARROW_VELOCITY,y=calc.y * ARROW_VELOCITY,z=calc.z * ARROW_VELOCITY})
				
				-- Play sound
				music_handle=minetest.sound_play("laser",{pos = pos, gain = 1.0, max_hear_distance = 50,})
			end
		end
	end
})

-- The Arrow Entity
THROWING_ARROW_ENTITY={
	physical = false,
	timer=0,
	visual_size = {x=0.2, y=0.2},
	textures = {"bullet.png"},
	lastpos={},
	collisionbox = {-0.17,-0.17,-0.17,0.17,0.17,0.17},
}
-- Arrow_entity.on_step()--> called when arrow is moving
THROWING_ARROW_ENTITY.on_step = function(self, dtime)
	self.timer=self.timer+dtime
	local pos = self.object:getpos()
	local node = minetest.env:get_node(pos)
	if self.timer > 2 then
		self.object:remove()
	end
	-- When arrow is away from player (after 0.2 seconds): Cause damage to mobs and players
	if self.timer>0.2 then
		local objs = minetest.env:get_objects_inside_radius({x=pos.x,y=pos.y,z=pos.z}, 1.5)
		for k, obj in pairs(objs) do
			if obj:is_player() then
				obj:set_hp(obj:get_hp()-ARROW_DAMAGE)
				self.object:remove()
			end
		end
	end
	
	if node.name ~= "air" and node.name ~= "turret:turret" then
		minetest.env:add_item(self.lastpos, 'throwing:arrow')
		self.object:remove()
	end
end

minetest.register_entity("turret:arrow_entity", THROWING_ARROW_ENTITY)

minetest.register_craft({
	output = "turret:turret",
	recipe = {
		{"default:mese_crystal", "default:gold_ingot", "default:mese_crystal"},
		{"default:gold_ingot", "default:mese_crystal", "default:gold_ingot"},
		{"default:mese_crystal", "default:gold_ingot", "default:mese_crystal"}
	}
})
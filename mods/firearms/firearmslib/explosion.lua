--[[
         DO WHAT THE FUCK YOU WANT TO PUBLIC LICENSE
                    Version 2, December 2004

 Copyright (C) 2004 Sam Hocevar <sam@hocevar.net>

 Everyone is permitted to copy and distribute verbatim or modified
 copies of this license document, and changing it is allowed as long
 as the name is changed.

            DO WHAT THE FUCK YOU WANT TO PUBLIC LICENSE
   TERMS AND CONDITIONS FOR COPYING, DISTRIBUTION AND MODIFICATION

  0. You just DO WHAT THE FUCK YOU WANT TO.
]]

local destroy = function(pos)
    if math.random(1,5) <= 4 then
        minetest.env:add_entity({x=pos.x+math.random(0,10)/10-0.5, y=pos.y, z=pos.z+math.random(0,10)/10-0.5}, "firearmslib:explosion_smoke")
    end
    local nodename = minetest.env:get_node(pos).name
    if nodename ~= "air" then
        minetest.env:remove_node(pos)
        nodeupdate(pos)
        if (firearmslib.EXPLOSION_SMOKE) then
            local obj = minetest.env:add_entity(pos, "firearmslib:explosion_debris")
            if obj == nil then
                return
            end
            obj:get_luaentity().collect = true
            obj:setacceleration({x=0, y=-10, z=0})
            obj:setvelocity({x=math.random(0,6)-3, y=10, z=math.random(0,6)-3})
        end
    end
end

firearmslib.explosion = function ( pos, bulletdef )
    minetest.env:remove_node(pos);
    local objects = minetest.env:get_objects_inside_radius(pos, bulletdef.explosion_range or 7);
    for _,obj in ipairs(objects) do
        if (obj:is_player() or (obj:get_luaentity() and obj:get_luaentity().name ~= "__builtin:item")) then
            local dist = kutils.distance3d(pos, obj:getpos());
            local damage = bulletdef.explosion_damage * (dist / bulletdef.explosion_range);
            obj:set_hp(obj.entity:get_hp() - damage);
            if (obj:get_hp() <= 0) then
                if (not obj:is_player()) then
                    obj:remove();
                end
                for i,f in ipairs(firearmslib.on_killentity_cbs) do
                    f(obj, player);
                end
            end
            --[[
            local obj_p = obj:getpos()
            local vec = {x=obj_p.x-pos.x, y=obj_p.y-pos.y, z=obj_p.z-pos.z}
            local dist = (vec.x^2+vec.y^2+vec.z^2)^0.5
            local damage = (80*0.5^dist)*2
            obj:punch(obj, 1.0, {
                full_punch_interval=1.0,
                groupcaps={
                    fleshy={times={[1]=1/damage, [2]=1/damage, [3]=1/damage}},
                    snappy={times={[1]=1/damage, [2]=1/damage, [3]=1/damage}},
                }
            }, nil)
            ]]
        end
    end
    
    for dx=-2,2 do
        for dz=-2,2 do
            for dy=2,-2,-1 do
                pos.x = pos.x+dx
                pos.y = pos.y+dy
                pos.z = pos.z+dz
                
                local node =  minetest.env:get_node(pos)
                if node.name == "fire:basic_flame" or string.find(node.name, "default:water_") or string.find(node.name, "default:lava_") or node.name == "tnt:boom" then
                    
                else
                    if math.abs(dx)<2 and math.abs(dy)<2 and math.abs(dz)<2 then
                        destroy(pos)
                    else
                        if math.random(1,5) <= 4 then
                            destroy(pos)
                        end
                    end
                end
                
                pos.x = pos.x-dx
                pos.y = pos.y-dy
                pos.z = pos.z-dz
            end
        end
    end
end

minetest.register_entity("firearmslib:explosion_smoke", {
    physical = true,
    visual = "sprite",
    textures = {"firearms_explosion_smoke.png"},
    collisionbox = {0,0,0,0,0,0},
    
    timer = 0,
    time = 5,
    
    on_activate = function(self, staticdata)
        self.object:setacceleration({x=math.random(0,10)/10-0.5, y=5, z=math.random(0,10)/10-0.5})
        self.time = math.random(1, 10)/10
    end,
    
    on_step = function(self, dtime)
        self.timer = self.timer+dtime
        if self.timer > self.time then
            self.object:remove()
        end
    end,
})

if minetest.setting_get("log_mods") then
    minetest.log("action", "tnt loaded")
end

minetest.register_entity("firearmslib:explosion_debris", {
    physical = true;
    timer = 0;
    textures = { "smoke_puff.png" };
    collisionbox = { 0, 0, 0, 0, 0, 0 };
    on_step = function ( self, dtime )
        self.timer = self.timer + dtime;
        if (self.timer >= 1) then
            self.object:remove();
            return;
        end
    end;
});


if (not kutils) then kutils = { }; end

-- Nodes to always ignore in checks. --
if (not kutils.ignore_nodes) then
    kutils.ignore_nodes = {
        ["air"] = true;
        ["default:water_source"] = true;
        ["default:water_flowing"] = true;
    };
end
    
-- Entities to always ignore in checks. --
if (not kutils.ignore_ents) then
    kutils.ignore_ents = {
        ["__builtin:item"] = true;
    };
end

--[[
  |  Cast a ray from a point in a direction.
  |
  |  The `params' argument must be a table with the following fields:
  |
  |    pos (required)
  |      Point from whihch to cast the ray.
  |
  |    delta (required)
  |      This controls the direction and step size ofthe check for collision.
  |      It must be a table { x=deltax, y=deltay, z=deltaz }
  |
  |    range (required)
  |      Number of steps to check. The distance checked is delta*range.
  |
  |    radius (optional)
  |      Radius for the entity checker. Smaller radius may miss some entities
  |      on the way; bigger radius may check for objects not really in the
  |      ray's path. Default is 1.
  |
  |    user (optional)
  |      This is the entity that is casting the ray. If not nil, this entity
  |      will be ignored in the check.
  |
  |    ignore_ents (optional)
  |      Table containing entity names to ignore in the check. In addition
  |      to the entities listed here, it ignores "__builtin:item". The format
  |      must be { ["modname:entname"] = true, ... }
  |
  |    solid_only (optional)
  |      If false, the ray takes not walkable nodes (e.g. lava) as solid. Air
  |      and water are always taken as not solid.
  |
  |    return_all (optional)
  |      If true, the function returns all nodes found by the ray.
  |
  |  Return value:
  |    If a node is hit by the ray, returns a table with `pos' and `node'
  |    fields. `pos' is the position where collision occurred, and `node' is
  |    the node info as returned by `minetest.env:get_node()'.
  |    If an entity is hit by the ray, returns a table with `pos' and `entity'
  |    fields. `pos' is as above, `entity' is an ObjectRef.
  |    If nothing is found, returns nil. Note that unloaded blocks are actual
  |    nodes! (check for node.name == "ignore" if you want to distinguish).
  |    Also note that if `params.return_all' is true, it will return an array
  |    where the items are in this format.
  ]]
if (not kutils.find_pointed_thing) then
    function kutils.find_pointed_thing ( params )
        local p = {x=params.pos.x, y=params.pos.y, z=params.pos.z};
        local dx, dy, dz = params.delta.x, params.delta.y, params.delta.z;
        local radius = params.radius or 0.75;
        local extra_ignore_ents = params.ignore_ents or { };
        local range = params.range;
        local solid_only = params.solid_only;
        local list = { };
        local listn = 1;
        for n = 0, range do
            local node = minetest.env:get_node(p);
            if (not kutils.ignore_nodes[node.name]) then
                if (solid_only) then
                    local walkable = minetest.registered_nodes[node.name].walkable;
                    if (walkable == false) then
                        if (not return_all) then
                            return {pos = p; node=node};
                        end
                        list[listn] = {pos = p; node=node};
                        listn = listn + 1;
                    end
                else
                    if (not return_all) then
                        return {pos = p; node=node};
                    end
                    list[listn] = {pos = p; node=node};
                    listn = listn + 1;
                end
            end
            local ents = minetest.env:get_objects_inside_radius(p, radius);
            if (#ents > 0) then
                for _,e in ipairs(ents) do
                    if ((e ~= params.user) and (not kutils.ignore_ents[e:get_entity_name()])
                     and (not extra_ignore_ents[e:get_entity_name()])) then
                        if (not return_all) then
                            return {pos=p; entity=e};
                        end
                        list[listn] = {pos = p; entity=e};
                        listn = listn + 1;
                    end
                end
            end
            p.x = p.x + dx;
            p.y = p.y + dy;
            p.z = p.z + dz;
        end
        if (listn > 1) then
            return list;
        end
        return nil;
    end
end

if (not kutils.distance3d) then
    function kutils.distance3d ( p1, p2 )
        local lenx = math.abs(p2.x - p1.x);
        local leny = math.abs(p2.y - p1.y);
        local lenz = math.abs(p2.z - p1.z);
        local hypotxz = math.sqrt((lenx * lenx) + (lenz * lenz));
        return math.sqrt((hypotxz * hypotxz) + (leny * leny));
    end
end

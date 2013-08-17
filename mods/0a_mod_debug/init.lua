-- check the settings
if minetest.setting_getbool("mod_debug")~=true then
	return
end

print("[DEBUG] Mod debug loaded")

local mod = {}
mod.recipes = {}
mod.aliases = {}

local register_craft = minetest.register_craft
local register_alias = minetest.register_alias

local function get_items_in_group(groupname)
	local items = {}
	for name, def in pairs(minetest.registered_nodes) do
		local g = def.groups and def.groups[groupname] or 0
		if g > 0 then
			items[name] = def
		end
	end
	return items
end

minetest.register_craft = function(recipe)
	register_craft(recipe)

	local name = mod.strip_name(recipe.output)
	if name~=nil then
		--print("[DEBUG] recipe for "..name.." registered")
		table.insert(mod.recipes,recipe)
	end
end

minetest.register_alias = function(new,old)
	register_alias (new,old)
	
	local name = mod.strip_name(new)
	local name2 = mod.strip_name(old)
	if name~=nil and name2~=nil then
		--print("[DEBUG] alias for "..name2.." to "..name.." registered")
		mod.aliases[new] = old
	end
end

function mod.assert(_name,output)
	local name = mod.strip_name(_name)
	if (name==nil) then
		return
	end
	
	if (mod.aliases[name]~=nil) then
		name = mod.aliases[name]
	end

	if (minetest.registered_items[name] == nil and next(get_items_in_group(name:gsub('%group:', '')))==nil) then
		print("[RECIPE ERROR] "..name.." in recipe for "..mod.strip_name(output))
	end
end

function mod.strip_name(name)
	if (name==nil) then
		return
	end

	res = name:gsub('%"', '')

	if res:sub(1,1) == ":" then
    		res = table.concat{res:sub(1,1-1), "", res:sub(1+1)}
	end

	for str in string.gmatch(res, "([^ ]+)") do
		if (str~=" " and str~=nil) then
			res=str
			break
		end
	end
	
	if (res==nil) then
		res=""
	end

	return res
end

-- Recursion method
function mod.check_recipe(table,output)
	if type(table) == "table" then
		for i=1,# table do
			mod.check_recipe(table[i],output)
		end
	else
		mod.assert(table,output)
	end
end


minetest.after(0, function()
	print("[DEBUG] checking recipes")
	for i=1,# mod.recipes do
		if mod.recipes[i] and mod.recipes[i].output then
			mod.assert(mod.recipes[i].output,mod.recipes[i].output)

			if type(mod.recipes[i].recipe) == "table" then
				for a=1,# mod.recipes[i].recipe do
					mod.check_recipe(mod.recipes[i].recipe[a],mod.recipes[i].output)
				end
			else
				mod.assert(mod.recipes[i].recipe,mod.recipes[i].output)
			end
		end
	end
end)
-- Registered
ctf.registered_on_load = {}
function ctf.register_on_load(func)
	if ctf._mt_loaded then
		error("You can't register callbacks at game time!")
	end
	table.insert(ctf.registered_on_load, func)
	if ctf._loaddata then
		func(ctf._loaddata)
	end
end
ctf.registered_on_save = {}
function ctf.register_on_save(func)
	if ctf._mt_loaded then
		error("You can't register callbacks at game time!")
	end
	table.insert(ctf.registered_on_save, func)
end
ctf.registered_on_init = {}
function ctf.register_on_init(func)
	if ctf._mt_loaded then
		error("You can't register callbacks at game time!")
	end
	table.insert(ctf.registered_on_init, func)
	if ctf._inited then
		func()
	end
end
ctf.registered_on_new_team = {}
function ctf.register_on_new_team(func)
	if ctf._mt_loaded then
		error("You can't register callbacks at game time!")
	end
	table.insert(ctf.registered_on_new_team, func)
end
ctf.registered_on_territory_query = {}
function ctf.register_on_territory_query(func)
	if ctf._mt_loaded then
		error("You can't register callbacks at game time!")
	end
	table.insert(ctf.registered_on_territory_query, func)
end

function vector.distanceSQ(p1, p2)
	local x = p1.x - p2.x
	local y = p1.y - p2.y
	local z = p1.z - p2.z
	return x*x + y*y + z*z
end



-- Debug helpers
function ctf.error(area, msg)
	minetest.log("error", "CTF::" .. area .. " - " ..msg)
end
function ctf.log(area, msg)
	if area and area ~= "" then
		print("[CaptureTheFlag] (" .. area .. ") " .. msg)
	else
		print("[CaptureTheFlag] " .. msg)
	end
end
function ctf.action(area, msg)
	if area and area ~= "" then
		minetest.log("action", "[CaptureTheFlag] (" .. area .. ") " .. msg)
	else
		nubetest.log("action", "[CaptureTheFlag] " .. msg)
	end
end
function ctf.warning(area, msg)
	print("WARNING: [CaptureTheFlag] (" .. area .. ") " .. msg)
end

function ctf.init()
	ctf._inited = true
	ctf.log("init", "Initialising!")

	-- Set up structures
	ctf._defsettings = {}
	ctf.teams = {}
	ctf.players = {}

	-- See minetest.conf.example in the root of this subgame

	ctf.log("init", "Creating Default Settings")
	ctf._set("diplomacy",                  true)
	ctf._set("players_can_change_team",    true)
	ctf._set("allocate_mode",              0)
	ctf._set("maximum_in_team",            -1)
	ctf._set("default_diplo_state",        "war")
	ctf._set("node_ownership",             true)
	ctf._set("hud",                        true)

	for i = 1, #ctf.registered_on_init do
		ctf.registered_on_init[i]()
	end

	ctf.load()

	ctf.log("init", "Done!")
end

function ctf.reset()
	ctf.log("io", "Deleting CTF save data...")
	os.remove(minetest.get_worldpath().."/ctf.txt")
	ctf.init()
end

-- Set default setting value
function ctf._set(setting, default)
	ctf._defsettings[setting] = default

	if minetest.setting_get("ctf."..setting) then
		ctf.log("init", "- " .. setting .. ": " .. minetest.setting_get("ctf."..setting))
	elseif minetest.setting_get("ctf_"..setting) then
		ctf.log("init", "- " .. setting .. ": " .. minetest.setting_get("ctf_"..setting))
		ctf.warning("init", "deprecated setting ctf_"..setting..
				" used, use ctf."..setting.." instead.")
	end
end

function ctf.setting(name)
	local set = minetest.setting_get("ctf."..name) or
			minetest.setting_get("ctf_"..name)
	local dset = ctf._defsettings[name]
	if dset == nil then
		ctf.error("setting", "No such setting - " .. name)
		return nil
	end

	if set ~= nil then
		if type(dset) == "number" then
			return tonumber(set)
		elseif type(dset) == "bool" then
			return minetest.is_yes(set)
		else
			return set
		end
	else
		return dset
	end
end

function ctf.load()
	ctf.log("io", "Loading CTF state")
	local file = io.open(minetest.get_worldpath().."/ctf.txt", "r")
	if file then
		local table = minetest.deserialize(file:read("*all"))
		if type(table) == "table" then
			ctf.teams = table.teams
			ctf.players = table.players

			for i = 1, #ctf.registered_on_load do
				ctf.registered_on_load[i](table)
			end
			return
		end
		ctf._loaddata = table
	else
		ctf.log("io", "ctf.txt is not present in the world folder")
	end
end

minetest.after(0, function()
	ctf._loaddata = nil
	ctf._mt_loaded = true
end)

function ctf.save()
	ctf.log("io", "Saving CTF state...")
	local file = io.open(minetest.get_worldpath().."/ctf.txt", "w")
	if file then
		local out = {
			teams = ctf.teams,
			players = ctf.players
		}

		for i = 1, #ctf.registered_on_save do
			local res = ctf.registered_on_save[i]()

			if res then
				for key, value in pairs(res) do
					out[key] = value
				end
			end
		end

		file:write(minetest.serialize(out))
		file:close()
		ctf.log("io", "Saved.")
	else
		ctf.error("io", "CTF file failed to save!")
	end
end

function ctf.get_territory_owner(pos)
	local largest = nil
	local largest_weight = 0
	for i = 1, #ctf.registered_on_territory_query do
		local team, weight = ctf.registered_on_territory_query[i](pos)
		if team and weight then
			if weight == -1 then
				return team
			end
			if weight > largest_weight then
				largest = team
				largest_weight = weight
			end
		end
	end
	return largest
end

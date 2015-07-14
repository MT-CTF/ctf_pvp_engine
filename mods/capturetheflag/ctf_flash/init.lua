ctf.register_on_init(function()
	ctf.log("flash", "Initialising...")
	ctf._set("remove_player_on_leave",     true)
	ctf._set("new_game.teams",             "")
	ctf._set("new_game.clear_inv",         false)
	-- ^ name, color, x, y, z; name, color, x, y, z
	-- ^ eg: red, red, 15, 7, 39; blue, blue, -9, 9, -43

end)

local function safe_place(pos, node)
	ctf.log("flash", "attempting to place...")
	minetest.get_voxel_manip(pos, { x = pos.x + 1, y = pos.y + 1, z = pos.z + 1})
	minetest.set_node(pos, node)
	if minetest.get_node(pos).name ~= node.name then
		ctf.error("flash", "failed to place node, retrying...")
		minetest.after(0.5, function()
			safe_place(pos, node)
		end)
	end
end

local claimed = ctf_flag.collect_claimed()
for i, flag in pairs(claimed) do
	flag.claimed = nil
end

minetest.register_on_joinplayer(function(player)
	if ctf.team(ctf.player(player:get_player_name()).team) then
		return
	end

	local alloc_mode = tonumber(ctf.setting("allocate_mode"))
	if alloc_mode == 0 then
		return
	end
	local name = player:get_player_name()
	local team = ctf.autoalloc(name, alloc_mode)
	if team then
		ctf.log("autoalloc", name .. " was allocated to " .. team)
		ctf.join(name, team)

		local spawn = ctf.get_spawn(team)
		if spawn then
			player:moveto(spawn, false)
		end
	end
end)

minetest.register_on_leaveplayer(function(player)
	if ctf.setting("remove_player_on_leave") then
		ctf.remove_player(player:get_player_name())
	end
end)

ctf.register_on_new_game(function()
	local teams = ctf.setting("new_game.teams")
	if teams:trim() == "" then
		return
	end
	ctf.log("flash", "Setting up new game!")

	teams = teams:split(";")
	local pos = {}
	for i, v in pairs(teams) do
		local team = v:split(",")
		if #team == 5 then
			local name  = team[1]:trim()
			local color = team[2]:trim()
			local x     = tonumber(team[3]:trim())
			local y     = tonumber(team[4]:trim())
			local z     = tonumber(team[5]:trim())
			pos[name] = {
				x = x,
				y = y,
				z = z
			}

			ctf.team({
				name=name,
				color=color,
				add_team=true
			})

			ctf_flag.add(name, pos[name])
		else
			ctf.warning("flash", "Invalid team setup: " .. dump(v))
		end
	end

	minetest.after(0, function()
		for name, p in pairs(pos) do
			safe_place(p, {name="ctf_flag:flag"})
			ctf_flag.update(p)
		end
	end)

	for i, player in pairs(minetest.get_connected_players()) do
		local name = player:get_player_name()
		local alloc_mode = tonumber(ctf.setting("allocate_mode"))
		local team = ctf.autoalloc(name, alloc_mode)

		if alloc_mode ~= 0 and team then
			ctf.log("autoalloc", name .. " was allocated to " .. team)
			ctf.join(name, team)
		end

		team = ctf.player(name).team
		if ctf.team(team) then
			local spawn = ctf.get_spawn(team)
			if spawn then
				player:moveto(spawn, false)
			end
		end

		if ctf.setting("new_game.clear_inv_on_new_game") then
			local inv = player:get_inventory()
			inv:set_list("main", {})
			inv:set_list("craft", {})
			give_initial_stuff(player)
		end

		player:set_hp(20)
	end
	minetest.chat_send_all("Next round!")
end)

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

ctf_flag.collect_claimed()
for i, flag in pairs(ctf_flag.claimed) do
	flag.claimed = nil
end
ctf_flag.collect_claimed()

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
	ctf.remove_player(player:get_player_name())
end)

ctf.register_on_new_game(function()
	ctf.log("flash", "Setting up new game!")

	ctf.team({name="red", color="red", add_team=true})
	ctf.team({name="blue", color="blue", add_team=true})

	local fred = {x=15, y=7, z=39, team="red"}
	local fblue = {x=-9, y=9, z=-43, team="blue"}
	ctf_flag.add("red", fred)
	ctf_flag.add("blue", fblue)

	minetest.after(0, function()
		safe_place(fred, {name="ctf_flag:flag"})
		safe_place(fblue, {name="ctf_flag:flag"})
		ctf_flag.update(fred)
		ctf_flag.update(fblue)
	end)

	for i, player in pairs(minetest.get_connected_players()) do
		local name = player:get_player_name()
		local inv = player:get_inventory()
		inv:set_list("main", {})
		inv:set_list("craft", {})

		local alloc_mode = tonumber(ctf.setting("allocate_mode"))
		if alloc_mode == 0 then
			return
		end
		local team = ctf.autoalloc(name, alloc_mode)
		if team then
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

		minetest.log("action", "Giving initial stuff to player "..player:get_player_name())
		player:get_inventory():add_item('main', 'default:pick_steel')
		player:get_inventory():add_item('main', 'default:sword_steel')
		player:get_inventory():add_item('main', 'default:cobble 99')
		player:set_hp(20)
	end
	minetest.chat_send_all("Next round!")
end)

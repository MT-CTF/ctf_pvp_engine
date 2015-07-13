ctf.register_on_init(function()
	ctf._set("endgame.destroy_team",       true)
	ctf._set("endgame.break_alliances",    true)
	ctf._set("endgame.reset_on_winner",    true)
end)

local function safe_place(pos, node)
	ctf.log("endgame", "attempting to place...")
	minetest.get_voxel_manip(pos, { x = pos.x + 1, y = pos.y + 1, z = pos.z + 1})
	minetest.set_node(pos, node)
	if minetest.get_node(pos).name ~= node.name then
		ctf.error("endgame", "failed to place node, retrying...")
		minetest.after(0.5, function()
			safe_place(pos, node)
		end)
	end
end

ctf_flag.register_on_capture(function(attname, flag)
	if not ctf.setting("endgame.destroy_team") then
		return
	end

	local fl_team = ctf.team(flag.team)
	if fl_team and #fl_team.flags == 0 then
		ctf.action("endgame", flag.team .. " was defeated.")
		ctf.remove_team(flag.team)
		minetest.chat_send_all(flag.team .. " has been defeated!")
	end

	if ctf.setting("endgame.reset_on_winner") then
		local winner = nil
		for name, team in pairs(ctf.teams) do
			if winner then
				return
			end
			winner = name
		end

		-- Only one team left!
		ctf.action("endgame", winner .. " won!")
		minetest.chat_send_all("Team " .. winner .. " won!")
		minetest.chat_send_all("Resetting the map, this may take a few moments...")
		minetest.after(0.5, function()
			ctf.reset()
			minetest.delete_area(vector.new(-16*3, -16*3, -16*3), vector.new(16*3, 16*3, 16*3))
			ctf.team({name="red", color="red", add_team=true})
			ctf.team({name="blue", color="blue", add_team=true})

			minetest.after(1, function()
				local fred = {x=15, y=7, z=39, team="red"}
				local fblue = {x=-9,y=9,z=-50, team="blue"}
				ctf_flag.add("red", fred)
				ctf_flag.add("blue", fblue)
				safe_place(fred, {name="ctf_flag:flag"})
				safe_place(fblue, {name="ctf_flag:flag"})

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
				end
				minetest.log("endgame", "reset done")
				minetest.chat_send_all("All done! Next round!")
			end)
		end)
	end
end)

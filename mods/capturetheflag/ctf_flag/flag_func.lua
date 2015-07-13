local function do_capture(attname, flag, returned)
	print("Do capture " .. attname)
	print(flag.x .. ", " .. flag.y .. ", " .. flag.z)

	local team = flag.team
	local attacker = ctf.player(attname)

	local flag_name = ""
	if flag.name then
		flag_name = flag.name .. " "
	end
	flag_name = team .. "'s " .. flag_name .. "flag"


	if ctf.setting("flag.capture_take") and not returned then
		minetest.chat_send_all(flag_name.." has been picked up by "..
				attname.." (team "..attacker.team..") from "..team)

		ctf.action("flag", attname .. " picked up " .. flag_name)

		-- Post to flag owner's board
		ctf.post(team, {
				msg = flag_name .. " has been taken by " .. attname .. " of ".. attacker.team,
				icon="flag_red" })

		-- Post to attacker's board
		ctf.post(attacker.team, {
				msg = attname .. " snatched '" .. flag_name .. "' from " .. team,
				icon="flag_green"})

		-- Add to claimed list
		flag.claimed = {
			team = attacker.team,
			player = attname
		}
		table.insert(ctf_flag.claimed, flag)

		for i = 1, #ctf_flag.registered_on_pick_up do
			ctf_flag.registered_on_pick_up[i](attname, flag)
		end
	else
		minetest.chat_send_all(flag_name.." has been captured from "..team..
				" by "..attname.." (team "..attacker.team..")")

		ctf.action("flag", attname .. " captured " .. flag_name)

		-- Post to flag owner's board
		ctf.post(team, {
				msg = flag_name .. " has been captured by " .. attacker.team,
				icon="flag_red"})

		-- Post to attacker's board
		ctf.post(attacker.team, {
				msg = attname .. " captured '" .. flag_name .. "' from " .. team,
				icon="flag_green"})

		-- Take flag
		if ctf.setting("flag.allow_multiple") then
			ctf_flag.delete(team, vector.new(flag))
			ctf_flag.add(attacker.team, vector.new(flag))
		else
			minetest.env:set_node(pos,{name="air"})
			ctf_flag.delete(team,pos)
		end

		for i = 1, #ctf_flag.registered_on_capture do
			ctf_flag.registered_on_capture[i](attname, flag)
		end
	end

	ctf.save()
end


ctf_flag = {
	on_punch_top = function(pos, node, puncher)
		pos.y = pos.y - 1
		ctf_flag.on_punch(pos, node, puncher)
	end,
	on_rightclick_top = function(pos, node, clicker)
		pos.y = pos.y - 1
		ctf_flag.on_rightclick(pos, node, clicker)
	end,
	on_rightclick = function(pos, node, clicker)
		local flag = ctf_flag.get(pos)
		if not flag then
			return
		end

		if flag.claimed then
			if ctf.setting("flag.capture_take") then
				minetest.chat_send_player(player, "This flag has been taken by "..flag.claimed.player)
				minetest.chat_send_player(player, "who is a member of team "..flag.claimed.team)
				return
			else
				minetest.chat_send_player(player, "Oops! This flag should not be captured. Reverting...")
				flag.claimed = nil
			end
		end
		ctf.gui.flag_board(clicker:get_player_name(),pos)
	end,
	on_punch = function(pos, node, puncher)
		local player = puncher:get_player_name()
		if not puncher or not player then
			return
		end

		local flag = ctf_flag.get(pos)
		if not flag then
			return
		end

		if flag.claimed then
			if ctf.setting("flag.capture_take") then
				minetest.chat_send_player(player, "This flag has been taken by " .. flag.claimed.player)
				minetest.chat_send_player(player, "who is a member of team " .. flag.claimed.team)
				return
			else
				minetest.chat_send_player(player, "Oops! This flag should not be captured. Reverting.")
				flag.claimed = nil
			end
		end

		local team = flag.team
		if not team then
			return
		end

		if ctf.team(team) and ctf.player(player).team then
			if ctf.player(player).team == team then
				-- Clicking on their team's flag
				if ctf.setting("flag.capture_take") then
					ctf_flag._flagret(player)
				end
			else
				-- Clicked on another team's flag
				local diplo = ctf.diplo.get(team, ctf.player(player).team) or
						ctf.setting("default_diplo_state")

				if diplo ~= "war" then
					minetest.chat_send_player(player, "You are at peace with this team!")
					return
				end

				do_capture(player, flag)
			end
		else
			minetest.chat_send_player(puncher:get_player_name(),"You are not part of a team!")
		end
	end,
	_flagret = function(player)
		minetest.chat_send_player(player, "Own flag")
		for i = 1, #ctf_flag.claimed do
			if ctf_flag.claimed[i].claimed.player == player then
				do_capture(player, ctf_flag.claimed[i], true)
				ctf_flag.collect_claimed()
			end
		end
	end,
	on_construct = function(pos)
		local meta = minetest.env:get_meta(pos)
		meta:set_string("infotext", "Unowned flag")
	end,
	after_place_node = function(pos, placer)
		if not pos then
			return
		end

		local meta = minetest.env:get_meta(pos)

		if not meta then
			return
		end

		if ctf.players and ctf.players[placer:get_player_name()] and ctf.players[placer:get_player_name()].team then
			local team = ctf.players[placer:get_player_name()].team
			meta:set_string("infotext", team.."'s flag")

			-- add flag
			ctf_flag.add(team, pos)

			if ctf.teams[team].spawn and minetest.env:get_node(ctf.teams[team].spawn).name == "ctf_flag:flag" then
				if not ctf.setting("flag.allow_multiple") then
					-- send message
					minetest.chat_send_all(team.."'s flag has been moved")
					minetest.env:set_node(ctf.team(team).spawn,{name="air"})
					minetest.env:set_node({
						x=ctf.team(team).spawn.x,
						y=ctf.team(team).spawn.y+1,
						z=ctf.team(team).spawn.z
					},{name="air"})
					ctf.team(team).spawn = pos
				end
			else
				ctf.get_spawn(team)
			end

			ctf.save()

			local pos2 = {
				x = pos.x,
				y = pos.y+1,
				z = pos.z
			}

			if not ctf.team(team).data.color then
				ctf.team(team).data.color = "red"
				ctf.save()
			end

			minetest.env:set_node(pos2, {name="ctf_flag:flag_top_"..ctf.team(team).data.color})

			local meta2 = minetest.env:get_meta(pos2)

			meta2:set_string("infotext", team.."'s flag")
		else
			minetest.chat_send_player(placer:get_player_name(), "You are not part of a team!")
			minetest.env:set_node(pos,{name="air"})
		end
	end
}

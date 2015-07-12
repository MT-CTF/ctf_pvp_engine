ctf_flag = {
	on_punch_top = function(pos, node, puncher)
		pos.y=pos.y-1

		ctf_flag.on_punch(pos, node, puncher)
	end,
	on_rightclick_top = function(pos, node, clicker)
		pos.y=pos.y-1

		local flag = ctf_flag.get(pos)
		if not flag then
			return
		end

		if flag.claimed then
			if ctf.setting("flag.capture_take") then
				minetest.chat_send_player(player, "This flag has been taken by ".. flag.claimed.player)
				minetest.chat_send_player(player, "who is a member of team ".. flag.claimed.team)
				return
			else
				minetest.chat_send_player(player, "Oops! This flag should not be captured. Reverting.")
				flag.claimed = nil
			end
		end

		ctf.gui.flag_board(clicker:get_player_name(),pos)
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
				minetest.chat_send_player(player, "This flag has been taken by "..flag.claimed.player)
				minetest.chat_send_player(player, "who is a member of team "..flag.claimed.team)
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
			if ctf.player(player).team ~= team then
				local diplo = ctf.diplo.get(team, ctf.player(player).team)

				if not diplo then
					diplo = ctf.setting("default_diplo_state")
				end

				if diplo ~= "war" then
					minetest.chat_send_player(player, "You are at peace with this team!")
					return
				end

				local flag_name = flag.name
				if ctf.setting("flag.capture_take") then
					if flag_name and flag_name~="" then
						minetest.chat_send_all(flag_name.." has been taken from "..team.." by "..player.." (team "..ctf.player(player).team..")")
						ctf.post(team,{msg=flag_name.." has been taken by "..ctf.player(player).team,icon="flag_red"})
						ctf.post(ctf.player(player).team,{msg=player.." snatched '"..flag_name.."' from "..team,icon="flag_green"})
					else
						minetest.chat_send_all(team.."'s flag at ("..pos.x..","..pos.z..") has taken by "..player.." (team "..ctf.player(player).team..")")
						ctf.post(team,{msg="The flag at ("..pos.x..","..pos.z..") has been taken by "..ctf.player(player).team,icon="flag_red"})
						ctf.post(ctf.player(player).team,{msg=player.." snatched flag ("..pos.x..","..pos.z..") from "..team,icon="flag_green"})
					end
					flag.claimed = {
						team = ctf.player(player).team,
						player = player
					}
					table.insert(ctf_flag.claimed, flag)
				else
					if flag_name and flag_name~="" then
						minetest.chat_send_all(flag_name.." has been taken from "..team.." by "..player.." (team "..ctf.player(player).team..")")
						ctf.post(team,{msg=flag_name.." has been captured by "..ctf.player(player).team,icon="flag_red"})
						ctf.post(ctf.player(player).team,{msg=player.." captured '"..flag_name.."' from "..team,icon="flag_green"})
					else
						minetest.chat_send_all(team.."'s flag at ("..pos.x..","..pos.z..") has been captured by "..player.." (team "..ctf.player(player).team..")")
						ctf.post(team,{msg="The flag at ("..pos.x..","..pos.z..") has been captured by "..ctf.player(player).team,icon="flag_red"})
						ctf.post(ctf.player(player).team,{msg=player.." captured flag ("..pos.x..","..pos.z..") from "..team,icon="flag_green"})
					end
					ctf.team(team).spawn = nil
					if ctf.setting("flag.allow_multiple") == true then
						ctf_flag.delete(team,pos)
						ctf_flag.add(ctf.player(player).team,pos)
					else
						minetest.env:set_node(pos,{name="air"})
						ctf_flag.delete(team,pos)
					end
				end
				ctf.save()
			else
				-- Clicking on their team's flag
				if ctf.setting("flag.capture_take") then
					ctf_flag._flagret(player)
				end
			end
		else
			minetest.chat_send_player(puncher:get_player_name(),"You are not part of a team!")
		end
	end,
	_flagret = function(player)
		minetest.chat_send_player(player,"Own flag")
		for i=1, #ctf_flag.claimed do
			if ctf_flag.claimed[i].claimed.player == player then
				minetest.chat_send_player(player,"Returning flag")
				local fteam = ctf.team(ctf_flag.claimed[i].team)
				local flag_name = ctf_flag.claimed[i].name
				if flag_name and flag_name~="" then
					minetest.chat_send_all(flag_name.." has been taken from "..fteam.data.name.." by "..ctf_flag.claimed[i].claimed.player.." (team "..ctf_flag.claimed[i].claimed.team..")")
					ctf.post(fteam,{msg=flag_name.." has been captured by "..ctf_flag.claimed[i].claimed.team,icon="flag_red"})
					ctf.post(ctf_flag.claimed[i].claimed.team,{msg=player.." captured '"..flag_name.."' from "..fteam.data.name,icon="flag_green"})
				else
					minetest.chat_send_all(fteam.data.name.."'s flag at ("..ctf_flag.claimed[i].x..","..ctf_flag.claimed[i].z..") has been captured by "..player.." (team "..ctf_flag.claimed[i].claimed.team..")")
					ctf.post(fteam.data.name,{msg="The flag at ("..ctf_flag.claimed[i].x..","..ctf_flag.claimed[i].z..") has been captured by "..ctf_flag.claimed[i].claimed.team,icon="flag_red"})
					ctf.post(ctf_flag.claimed[i].claimed.team,{msg=player.." captured flag ("..ctf_flag.claimed[i].x..","..ctf_flag.claimed[i].z..") from "..fteam.data.name,icon="flag_green"})
				end
				fteam.spawn = nil
				local fpos = {x=ctf_flag.claimed[i].x,y=ctf_flag.claimed[i].y,z=ctf_flag.claimed[i].z}
				if ctf.setting("flag.allow_multiple") == true then
					ctf_flag.delete(fteam.data.name,fpos)
					ctf_flag.add(ctf_flag.claimed[i].claimed.team,fpos)
				else
					minetest.env:set_node(fpos,{name="air"})
					ctf_flag.delete(fteam.data.name,fpos)
				end
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
				ctf.area.get_spawn(team)
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

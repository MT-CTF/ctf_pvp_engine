ctf.flag_func = {
	on_punch_top = function(pos, node, puncher)
		pos.y=pos.y-1

		ctf.flag_func.on_punch(pos,node,puncher)
	end,
	on_rightclick_top = function(pos, node, clicker)
		pos.y=pos.y-1

		local flag = ctf.area.get_flag(pos)
		if not flag then
			return
		end

		if flag.claimed then
			if ctf.setting("flag_capture_take") then
				minetest.chat_send_player(player,"This flag has been taken by "..flag.claimed.player)
				minetest.chat_send_player(player,"who is a member of team "..flag.claimed.team)
				return
			else
				minetest.chat_send_player(player,"Oops! This flag should not be captured. Reverting.")
				flag.claimed = nil
			end
		end

		ctf.gui.flag_board(clicker:get_player_name(),pos)
	end,
	on_rightclick = function(pos, node, clicker)
		local flag = ctf.area.get_flag(pos)
		if not flag then
			return
		end

		if flag.claimed then
			if ctf.setting("flag_capture_take") then
				minetest.chat_send_player(player,"This flag has been taken by "..flag.claimed.player)
				minetest.chat_send_player(player,"who is a member of team "..flag.claimed.team)
				return
			else
				minetest.chat_send_player(player,"Oops! This flag should not be captured. Reverting.")
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

		local flag = ctf.area.get_flag(pos)
		if not flag then
			return
		end

		if flag.claimed then
			if ctf.setting("flag_capture_take") then
				minetest.chat_send_player(player,"This flag has been taken by "..flag.claimed.player)
				minetest.chat_send_player(player,"who is a member of team "..flag.claimed.team)
				return
			else
				minetest.chat_send_player(player,"Oops! This flag should not be captured. Reverting.")
				flag.claimed = nil
			end
		end

		local team = flag.team
		if not team then
			return
		end

		if ctf.players and ctf.team(team) and ctf.player(player) and ctf.player(player).team then
			if ctf.player(player).team ~= team then
				local diplo = ctf.diplo.get(team,ctf.player(player).team)

				if not diplo then
					diplo = ctf.setting("default_diplo_state")
				end

				if diplo ~= "war" then
					minetest.chat_send_player(player,"You are at peace with this team!")
					return
				end

				--ctf.post(team,{msg=flag_name.." has been captured by "..ctf.player(player).team,icon="flag_red"})
				--ctf.post(ctf.player(player).team,{msg=player.." captured '"..flag_name.."' from "..team,icon="flag_green"})
				--ctf.post(team,{msg="The flag at ("..pos.x..","..pos.z..") has been captured by "..ctf.player(player).team,icon="flag_red"})
				--ctf.post(ctf.player(player).team,{msg=player.." captured flag ("..pos.x..","..pos.z..") from "..team,icon="flag_green"})

				local flag_name = flag.name
				if ctf.setting("flag_capture_take") then
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
					table.insert(ctf.claimed, flag)
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
					if ctf.setting("multiple_flags") == true then
						ctf.area.delete_flag(team,pos)
						ctf.area.add_flag(ctf.player(player).team,pos)
					else
						minetest.env:set_node(pos,{name="air"})
						ctf.area.delete_flag(team,pos)
					end
				end
				ctf.save()
			else
				-- Clicking on their team's flag
				if ctf.setting("flag_capture_take") then
					ctf.flag_func._flagret(player)
				end
			end
		else
			minetest.chat_send_player(puncher:get_player_name(),"You are not part of a team!")
		end
	end,
	_flagret = function(player)
		minetest.chat_send_player(player,"Own flag")
		for i=1, #ctf.claimed do
			if ctf.claimed[i].claimed.player == player then
				minetest.chat_send_player(player,"Returning flag")
				local fteam = ctf.team(ctf.claimed[i].team)
				local flag_name = ctf.claimed[i].name
				if flag_name and flag_name~="" then
					minetest.chat_send_all(flag_name.." has been taken from "..fteam.data.name.." by "..ctf.claimed[i].claimed.player.." (team "..ctf.claimed[i].claimed.team..")")
					ctf.post(fteam,{msg=flag_name.." has been captured by "..ctf.claimed[i].claimed.team,icon="flag_red"})
					ctf.post(ctf.claimed[i].claimed.team,{msg=player.." captured '"..flag_name.."' from "..fteam.data.name,icon="flag_green"})
				else
					minetest.chat_send_all(fteam.data.name.."'s flag at ("..ctf.claimed[i].x..","..ctf.claimed[i].z..") has been captured by "..player.." (team "..ctf.claimed[i].claimed.team..")")
					ctf.post(fteam.data.name,{msg="The flag at ("..ctf.claimed[i].x..","..ctf.claimed[i].z..") has been captured by "..ctf.claimed[i].claimed.team,icon="flag_red"})
					ctf.post(ctf.claimed[i].claimed.team,{msg=player.." captured flag ("..ctf.claimed[i].x..","..ctf.claimed[i].z..") from "..fteam.data.name,icon="flag_green"})
				end
				fteam.spawn = nil
				local fpos = {x=ctf.claimed[i].x,y=ctf.claimed[i].y,z=ctf.claimed[i].z}
				if ctf.setting("multiple_flags") == true then
					ctf.area.delete_flag(fteam.data.name,fpos)
					ctf.area.add_flag(ctf.claimed[i].claimed.team,fpos)
				else
					minetest.env:set_node(fpos,{name="air"})
					ctf.area.delete_flag(fteam.data.name,fpos)
				end
				ctf.collect_claimed()
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
			ctf.area.add_flag(team,pos)

			if ctf.teams[team].spawn and minetest.env:get_node(ctf.teams[team].spawn).name == "ctf:flag" then
				if not ctf.setting("multiple_flags") then
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
						x=pos.x,
						y=pos.y+1,
						z=pos.z
					}

			if not ctf.team(team).data.color then
				ctf.team(team).data.color = "red"
				ctf.save()
			end

			minetest.env:set_node(pos2,{name="ctf:flag_top_"..ctf.team(team).data.color})

			local meta2 = minetest.env:get_meta(pos2)

			meta2:set_string("infotext", team.."'s flag")
		else
			minetest.chat_send_player(placer:get_player_name(),"You are not part of a team!")
			minetest.env:set_node(pos,{name="air"})
		end
	end
}

-- The flag
minetest.register_node("ctf:flag",{
	description = "Flag",
	drawtype="nodebox",
	paramtype = "light",
	walkable = false,
	tiles = {
		"default_wood.png",
		"default_wood.png",
		"default_wood.png",
		"default_wood.png",
		"default_wood.png",
		"default_wood.png"
	},
	node_box = {
		type = "fixed",
		fixed = {
			{0.250000,-0.500000,0.000000,0.312500,0.500000,0.062500}
		}
	},
	groups = {immortal=1,is_flag=1,flag_bottom=1},
	on_punch = ctf.flag_func.on_punch,
	on_rightclick = ctf.flag_func.on_rightclick,
	on_construct = ctf.flag_func.on_construct,
	after_place_node = ctf.flag_func.after_place_node
})
ctf.flag_colors = {
	red   = "0xFF0000",
	green = "0x00FF00",
	blue  = "0x0000FF"
}

for color, _ in pairs(ctf.flag_colors) do
	minetest.register_node("ctf:flag_top_"..color,{
		description = "You are not meant to have this! - flag top",
		drawtype="nodebox",
		paramtype = "light",
		walkable = false,
		tiles = {
			"default_wood.png",
			"default_wood.png",
			"default_wood.png",
			"default_wood.png",
			"flag_"..color.."2.png",
			"flag_"..color..".png"
		},
		node_box = {
			type = "fixed",
			fixed = {
				{0.250000,-0.500000,0.000000,0.312500,0.500000,0.062500},
				{-0.5,0,0.000000,0.250000,0.500000,0.062500}
			}
		},
		groups = {immortal=1,is_flag=1,flag_top=1,not_in_creative_inventory=1},
		on_punch = ctf.flag_func.on_punch_top,
		on_rightclick = ctf.flag_func.on_rightclick_top
	})
end

minetest.register_node("ctf:flag_captured_top",{
	description = "You are not meant to have this! - flag captured",
	drawtype="nodebox",
	paramtype = "light",
	walkable = false,
	tiles = {
		"default_wood.png",
		"default_wood.png",
		"default_wood.png",
		"default_wood.png",
		"default_wood.png",
		"default_wood.png"
	},
	node_box = {
		type = "fixed",
		fixed = {
			{0.250000,-0.500000,0.000000,0.312500,0.500000,0.062500}
		}
	},
	groups = {immortal=1,is_flag=1,flag_top=1,not_in_creative_inventory=1},
	on_punch = ctf.flag_func.on_punch_top,
	on_rightclick = ctf.flag_func.on_rightclick_top
})

-- On respawn
minetest.register_on_respawnplayer(function(player)
	if player and ctf.player(player:get_player_name()) then
		local team = ctf.player(player:get_player_name()).team
		if team and ctf.team(team) and ctf.area.get_spawn(team)==true then
			print("Player "..player:get_player_name().." moved to team spawn")
			player:moveto(ctf.team(team).spawn, false)
			return true
		end
	end

	return false
end)

minetest.register_abm({
	nodenames = {"group:flag_bottom"},
	inteval = 5,
	chance = 1,
	action = function(pos)
		local top = {x=pos.x,y=pos.y+1,z=pos.z}
		local flagmeta = minetest.env:get_meta(pos)

		if not flagmeta then
			return
		end

		local flag_team_data = ctf.area.get_flag(pos)
		if not flag_team_data or not ctf.team(flag_team_data.team)then
			print("Flag does not exist! "..dump(pos))
			minetest.env:set_node(pos,{name="air"})
			minetest.env:set_node(top,{name="air"})
			return
		end
		local topmeta = minetest.env:get_meta(top)
		local flag_name = flag_team_data.name
		if flag_name and flag_name ~= "" then
			flagmeta:set_string("infotext", flag_name.." - "..flag_team_data.team)
		else
			flagmeta:set_string("infotext", flag_team_data.team.."'s flag")
		end

		if not ctf.team(flag_team_data.team).data.color then
			ctf.team(flag_team_data.team).data.color = "red"
			ctf.save()
		end

		if flag_team_data.claimed then
			minetest.env:set_node(top,{name="ctf:flag_captured_top"})
		else
			minetest.env:set_node(top,{name="ctf:flag_top_"..ctf.team(flag_team_data.team).data.color})
		end

		topmeta = minetest.env:get_meta(top)
		if flag_name and flag_name ~= "" then
			topmeta:set_string("infotext", flag_name.." - "..flag_team_data.team)
		else
			topmeta:set_string("infotext", flag_team_data.team.."'s flag")
		end
	end
})

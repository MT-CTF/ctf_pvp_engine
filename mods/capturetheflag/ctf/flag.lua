cf.flag_func = {
	on_punch_top = function(pos, node, puncher)
		pos.y=pos.y-1
			
		cf.flag_func.on_punch(pos,node,puncher)
	end,
	on_rightclick_top = function(pos, node, clicker)
		pos.y=pos.y-1
		
		local flag = cf.area.get_flag(pos)
		if not flag then
			return
		end
		
		if flag.claimed then
			if cf.setting("flag_capture_take") then
				minetest.chat_send_player(player,"This flag has been taken by "..flag.claimed.player)
				minetest.chat_send_player(player,"who is a member of team "..flag.claimed.team)
				return
			else
				minetest.chat_send_player(player,"Oops! This flag should not be captured. Reverting.")
				flag.claimed = nil
			end
		end
		
		cf.gui.flag_board(clicker:get_player_name(),pos)
	end,
	on_rightclick = function(pos, node, clicker)	
		local flag = cf.area.get_flag(pos)
		if not flag then
			return
		end
		
		if flag.claimed then
			if cf.setting("flag_capture_take") then
				minetest.chat_send_player(player,"This flag has been taken by "..flag.claimed.player)
				minetest.chat_send_player(player,"who is a member of team "..flag.claimed.team)
				return
			else
				minetest.chat_send_player(player,"Oops! This flag should not be captured. Reverting.")
				flag.claimed = nil
			end
		end		
		cf.gui.flag_board(clicker:get_player_name(),pos)
	end,
	on_punch = function(pos, node, puncher)
		local player = puncher:get_player_name()
		if not puncher or not player then
			return
		end
		
		local flag = cf.area.get_flag(pos)
		if not flag then
			return
		end
		
		if flag.claimed then
			if cf.setting("flag_capture_take") then
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

		if cf.players and cf.team(team) and cf.player(player) and cf.player(player).team then
			if cf.player(player).team ~= team then
				local diplo = cf.diplo.get(team,cf.player(player).team)
				
				if not diplo then
					diplo = cf.setting("default_diplo_state")
				end

				if diplo ~= "war" then
					minetest.chat_send_player(player,"You are at peace with this team!")
					return
				end
				
				--cf.post(team,{msg=flag_name.." has been captured by "..cf.player(player).team,icon="flag_red"})
				--cf.post(cf.player(player).team,{msg=player.." captured '"..flag_name.."' from "..team,icon="flag_green"})
				--cf.post(team,{msg="The flag at ("..pos.x..","..pos.z..") has been captured by "..cf.player(player).team,icon="flag_red"})
				--cf.post(cf.player(player).team,{msg=player.." captured flag ("..pos.x..","..pos.z..") from "..team,icon="flag_green"})

				local flag_name = flag.name
				if cf.setting("flag_capture_take") then
					if flag_name and flag_name~="" then
						minetest.chat_send_all(flag_name.." has been taken from "..team.." by "..player.." (team "..cf.player(player).team..")")
						cf.post(team,{msg=flag_name.." has been taken by "..cf.player(player).team,icon="flag_red"})
						cf.post(cf.player(player).team,{msg=player.." snatched '"..flag_name.."' from "..team,icon="flag_green"})						
					else
						minetest.chat_send_all(team.."'s flag at ("..pos.x..","..pos.z..") has taken by "..player.." (team "..cf.player(player).team..")")
						cf.post(team,{msg="The flag at ("..pos.x..","..pos.z..") has been taken by "..cf.player(player).team,icon="flag_red"})
						cf.post(cf.player(player).team,{msg=player.." snatched flag ("..pos.x..","..pos.z..") from "..team,icon="flag_green"})						
					end
					flag.claimed = {
						team = cf.player(player).team,
						player = player
					}
					table.insert(cf.claimed, flag)
				else
					if flag_name and flag_name~="" then
						minetest.chat_send_all(flag_name.." has been taken from "..team.." by "..player.." (team "..cf.player(player).team..")")
						cf.post(team,{msg=flag_name.." has been captured by "..cf.player(player).team,icon="flag_red"})
						cf.post(cf.player(player).team,{msg=player.." captured '"..flag_name.."' from "..team,icon="flag_green"})
					else
						minetest.chat_send_all(team.."'s flag at ("..pos.x..","..pos.z..") has been captured by "..player.." (team "..cf.player(player).team..")")
						cf.post(team,{msg="The flag at ("..pos.x..","..pos.z..") has been captured by "..cf.player(player).team,icon="flag_red"})
						cf.post(cf.player(player).team,{msg=player.." captured flag ("..pos.x..","..pos.z..") from "..team,icon="flag_green"})
					end
					cf.team(team).spawn = nil
					if cf.setting("multiple_flags") == true then
						cf.area.delete_flag(team,pos)
						cf.area.add_flag(cf.player(player).team,pos)
					else
						minetest.env:set_node(pos,{name="air"})
						cf.area.delete_flag(team,pos)
					end
				end
				cf.save()
			else
				-- Clicking on their team's flag
				if cf.setting("flag_capture_take") then
					cf.flag_func._flagret(player)
				end				
			end
		else
			minetest.chat_send_player(puncher:get_player_name(),"You are not part of a team!")
		end
	end,
	_flagret = function(player)
		minetest.chat_send_player(player,"Own flag")
		for i=1, #cf.claimed do
			if cf.claimed[i].claimed.player == player then
				minetest.chat_send_player(player,"Returning flag")
				local fteam = cf.team(cf.claimed[i].team)
				local flag_name = cf.claimed[i].name
				if flag_name and flag_name~="" then
					minetest.chat_send_all(flag_name.." has been taken from "..fteam.data.name.." by "..cf.claimed[i].claimed.player.." (team "..cf.claimed[i].claimed.team..")")
					cf.post(fteam,{msg=flag_name.." has been captured by "..cf.claimed[i].claimed.team,icon="flag_red"})
					cf.post(cf.claimed[i].claimed.team,{msg=player.." captured '"..flag_name.."' from "..fteam.data.name,icon="flag_green"})
				else
					minetest.chat_send_all(fteam.data.name.."'s flag at ("..cf.claimed[i].x..","..cf.claimed[i].z..") has been captured by "..player.." (team "..cf.claimed[i].claimed.team..")")
					cf.post(fteam.data.name,{msg="The flag at ("..cf.claimed[i].x..","..cf.claimed[i].z..") has been captured by "..cf.claimed[i].claimed.team,icon="flag_red"})
					cf.post(cf.claimed[i].claimed.team,{msg=player.." captured flag ("..cf.claimed[i].x..","..cf.claimed[i].z..") from "..fteam.data.name,icon="flag_green"})
				end
				fteam.spawn = nil
				local fpos = {x=cf.claimed[i].x,y=cf.claimed[i].y,z=cf.claimed[i].z}
				if cf.setting("multiple_flags") == true then								
					cf.area.delete_flag(fteam.data.name,fpos)
					cf.area.add_flag(cf.claimed[i].claimed.team,fpos)
				else
					minetest.env:set_node(fpos,{name="air"})
					cf.area.delete_flag(fteam.data.name,fpos)
				end
				cf.collect_claimed()
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

		if cf.players and cf.players[placer:get_player_name()] and cf.players[placer:get_player_name()].team then
			local team = cf.players[placer:get_player_name()].team
			meta:set_string("infotext", team.."'s flag")
			
			-- add flag
			cf.area.add_flag(team,pos)

			if cf.teams[team].spawn and minetest.env:get_node(cf.teams[team].spawn).name == "ctf:flag" then
				if not cf.setting("multiple_flags") then
					-- send message
					minetest.chat_send_all(team.."'s flag has been moved")
					minetest.env:set_node(cf.team(team).spawn,{name="air"})
					minetest.env:set_node({
						x=cf.team(team).spawn.x,
						y=cf.team(team).spawn.y+1,
						z=cf.team(team).spawn.z
					},{name="air"})
					cf.team(team).spawn = pos
				end
			else
				cf.area.get_spawn(team)
			end

			cf.save()
			
			local pos2 = {
						x=pos.x,
						y=pos.y+1,
						z=pos.z
					}
					
			if not cf.team(team).data.color then
				cf.team(team).data.color = "red"
				cf.save()
			end

			minetest.env:set_node(pos2,{name="ctf:flag_top_"..cf.team(team).data.color})
			
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
	on_punch = cf.flag_func.on_punch,
	on_rightclick = cf.flag_func.on_rightclick,
	on_construct = cf.flag_func.on_construct,
	after_place_node = cf.flag_func.after_place_node
})
local colors = {"red","green","blue"}

for i=1,#colors do
	local color = colors[i]
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
		on_punch = cf.flag_func.on_punch_top,
		on_rightclick = cf.flag_func.on_rightclick_top
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
	on_punch = cf.flag_func.on_punch_top,
	on_rightclick = cf.flag_func.on_rightclick_top
})

-- On respawn
minetest.register_on_respawnplayer(function(player)
	if player and cf.player(player:get_player_name()) then
		local team = cf.player(player:get_player_name()).team
		if team and cf.team(team) and cf.area.get_spawn(team)==true then
			print("Player "..player:get_player_name().." moved to team spawn")
			player:moveto(cf.team(team).spawn, false)
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

		local flag_team_data = cf.area.get_flag(pos)
		if not flag_team_data or not cf.team(flag_team_data.team)then
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

		if not cf.team(flag_team_data.team).data.color then
			cf.team(flag_team_data.team).data.color = "red"
			cf.save()
		end

		if flag_team_data.claimed then		
			minetest.env:set_node(top,{name="ctf:flag_captured_top"})
		else
			minetest.env:set_node(top,{name="ctf:flag_top_"..cf.team(flag_team_data.team).data.color})
		end
		
		topmeta = minetest.env:get_meta(top)
		if flag_name and flag_name ~= "" then
			topmeta:set_string("infotext", flag_name.." - "..flag_team_data.team)
		else
			topmeta:set_string("infotext", flag_team_data.team.."'s flag")
		end
	end
})
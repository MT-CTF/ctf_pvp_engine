ctf.gui = {}

if ctf.setting("team_gui") and ctf.setting("gui") then -- check if team guis are enabled
	-- Get tab buttons
	function ctf.gui.tabs(name,team)
		local result = ""
		local id = 1
		local function addtab(name,text)
			result = result .. "button["..(id*2-1)..",0;2,1;"..name..";"..text.."]"
			id = id + 1
		end
		if ctf.setting("news_gui") then
			addtab("board","News")
		end		
		if ctf.setting("flag_teleport_gui") then
			addtab("flags","Flags")
		end
		if ctf.setting("diplomacy") then
			addtab("diplo","Diplomacy")
		end
		addtab("admin","Settings")
		return result
	end
	
	-- Team interface
	function ctf.gui.team_board(name,team)
		local result = ""
		local data = ctf.teams[team].log
	
		if not data then
			data = {}
		end

		local amount = 0

		for i=1,#data do
			if data[i].type == "request" then
				if ctf.can_mod(name,team)==true then
					amount = amount + 2
					local height = (amount*0.5) + 0.5
					amount = amount + 1

					if data[i].mode == "diplo" then
						result = result .. "image[0.5,".. height ..";10.5,1;diplo_"..data[i].msg..".png]"
						if data[i].msg == "alliance" then
							result = result .. "label[1,".. height ..";".. data[i].team .." offers an "..minetest.formspec_escape(data[i].msg).." treaty]"
						else
							result = result .. "label[1,".. height ..";".. data[i].team .." offers a "..minetest.formspec_escape(data[i].msg).." treaty]"
						end
						result = result .. "button[6,".. height ..";1,1;btn_y"..i..";Yes]"
						result = result .. "button[7,".. height ..";1,1;btn_n"..i..";No]"
					else
						result = result .. "label[0.5,".. height ..";RANDOM REQUEST TYPE]"
					end
				end
			else
				amount = amount + 1
				local height = (amount*0.5)+0.5

				if height > 5 then
					print("break!")
					break
				end
			

				result = result .. "label[0.5,".. height ..";".. minetest.formspec_escape(data[i].msg) .."]"
			end
		end

		if ctf.can_mod(name,team)==true then
			result = result .. "button[4,6;2,1;clear;Clear all]"
		end

		if amount == 0 then
			result = "label[0.5,1;Welcome to the news panel]"..
				"label[0.5,1.5;News such as attacks will appear here]"
		end

		minetest.show_formspec(name, "ctf:board",
			"size[10,7]"..
			ctf.gui.tabs(name,team)..
			result
		)
	end

	-- Team interface
	function ctf.gui.team_flags(name,team)
		local result = ""
		local t = ctf.team(team)
		
		if not t then
			return		
		end
		
		local x = 1
		local y = 2
		result = result .. "label[1,1;Click a flag button to go there]"

		if ctf.setting("spawn_in_flag_teleport_gui") and minetest.get_setting("static_spawnpoint") then
			local x,y,z = string.match(minetest.get_setting("static_spawnpoint"),"(%d+),(%d+),(%d+)")

			result = result ..
				"button[" .. x .. "," .. y .. ";2,1;goto_"
				..f.x.."_"..f.y.."_"..f.z..";"

			result = result ..  "Spawn]"
			x = x + 2
		end
		
		for i=1,#t.flags do
			local f = t.flags[i]			
			
			if x > 8 then
				x = 1
				y = y + 1			
			end
			
			if y > 6 then
				break
			end
			
			result = result ..
				"button[" .. x .. "," .. y .. ";2,1;goto_"
				..f.x.."_"..f.y.."_"..f.z..";"
			
			if f.name then
				result = result .. f.name .. "]"	
			else
				result = result .. "("..f.x..","..f.y..","..f.z..")]"			
			end	

			x = x + 2
		end
	
		minetest.show_formspec(name, "ctf:flags",
			"size[10,7]"..
			ctf.gui.tabs(name,team)..
			result
		)
	end
	
	-- Team interface
	function ctf.gui.team_dip(name,team)
		local result = ""
		local data = {}

		local amount = 0
		
		for key,value in pairs(ctf.teams) do
			if key ~= team then
				table.insert(data,{
						team = key,
						state = ctf.diplo.get(team,key),
						to = ctf.diplo.check_requests(team,key),
						from = ctf.diplo.check_requests(key,team)
					})
			end
		end

		result = result .. "label[1,1;Diplomacy from the perspective of "..team.."]"

		for i=1,#data do
			amount = i
			local height = (i*1)+0.5

			if height > 5 then
				break
			end

			result = result .. "image[1,".. height ..";10,1;diplo_"..data[i].state..".png]"
			result = result .. "button[1.25,".. height ..";2,1;team_".. data[i].team ..";".. data[i].team .."]"
			result = result .. "label[3.75,".. height ..";".. data[i].state .."]"

			if ctf.can_mod(name,team)==true and ctf.player(name).team == team then
				if not data[i].from and not data[i].to then
					if data[i].state == "war" then
						result = result .. "button[7.5,".. height ..";1.5,1;peace_".. data[i].team ..";Peace]"
					elseif data[i].state == "peace" then
						result = result .. "button[6,".. height ..";1.5,1;war_".. data[i].team ..";War]"
						result = result .. "button[7.5,".. height ..";1.5,1;alli_".. data[i].team ..";Alliance]"
					elseif data[i].state == "alliance" then
						result = result .. "button[6,".. height ..";1.5,1;peace_".. data[i].team ..";Peace]"
					end
				elseif data[i].from ~= nil then
					result = result .. "label[6,".. height ..";request recieved]"
				elseif data[i].to ~= nil then
					result = result .. "label[5.5,".. height ..";request sent]"
					result = result .. "button[7.5,".. height ..";1.5,1;cancel_".. data[i].team ..";Cancel]"
				end
			end
		end
	
		minetest.show_formspec(name, "ctf:dip",
			"size[10,7]"..
			ctf.gui.tabs(name,team)..
			result
		)
	end
	
	-- Team interface
	function ctf.gui.team_settings(name,team)
		if not team or not ctf.team(team) then
			return
		end
	
		local color = ""

		if ctf.team(team).data and ctf.team(team).data.color then
			color = ctf.team(team).data.color
		end
	
		local result = "field[3,2;4,1;color;Team Color;"..color.."]"..
			"button[4,6;2,1;save;Save]"
	
	
		if ctf.can_mod(name,team) == false then
			result = "label[0.5,1;You do not own this team!"
		end
	
		minetest.show_formspec(name, "ctf:team_settings",
			"size[10,7]"..
			ctf.gui.tabs(name,team)..
			result
		)
	end
	minetest.register_on_player_receive_fields(function(player, formname, fields)
		local name = player:get_player_name()
		if formname=="ctf:board" or formname=="ctf:flags" or formname=="ctf:dip" or formname=="ctf:team_settings" then
			if fields.flags then
				if ctf and ctf.players and ctf.players[name] and ctf.players[name].team then
					ctf.gui.team_flags(name,ctf.players[name].team)
				end
				return true
			end
			if fields.board then
				if ctf and ctf.players and ctf.players[name] and ctf.players[name].team then
					ctf.gui.team_board(name,ctf.players[name].team)
				end
				return true
			end
			if fields.diplo then
				if ctf and ctf.players and ctf.players[name] and ctf.players[name].team then
					ctf.gui.team_dip(name,ctf.players[name].team)
				end
				return true
			end
			if fields.admin then
				if ctf and ctf.players and ctf.players[name] and ctf.players[name].team then
					ctf.gui.team_settings(name,ctf.players[name].team)
				end
				return true
			end
			if fields.clear then
				if ctf and ctf.players and ctf.players[name] and ctf.players[name].team then
					ctf.team(ctf.players[name].team).log = {}
					ctf.save()
					ctf.gui.team_board(name,ctf.players[name].team)
				end
				return true
			end
			if fields.save and formname=="ctf:team_settings" then
				if ctf and ctf.players and ctf.players[name] and ctf.players[name].team then
					ctf.gui.team_settings(name,ctf.players[name].team)
				end
				if ctf and ctf.team(ctf.players[name].team) and ctf.team(ctf.players[name].team).data then
					if minetest.registered_items["ctf:flag_top_"..fields.color] then
						print("Setting color...")
						ctf.team(ctf.players[name].team).data.color = fields.color
						ctf.save()
					else
						minetest.chat_send_player(name,"Color "..fields.color.." does not exist!")
					end
				end
				return true
			end
		end
	end)

	minetest.register_on_player_receive_fields(function(player, formname, fields)
		local name = player:get_player_name()
		if formname=="ctf:board" then
			for key, field in pairs(fields) do
				local ok, id = string.match(key, "btn_([yn])([0123456789]+)")
				if ok and id then
					if ctf.player(name) and ctf.player(name).team and ctf.team(ctf.player(name).team) then
						if ok == "y" then
							ctf.diplo.set(ctf.player(name).team, ctf.team(ctf.player(name).team).log[tonumber(id)].team, ctf.team(ctf.player(name).team).log[tonumber(id)].msg)
							ctf.post(ctf.player(name).team,{msg="You have accepted the "..ctf.team(ctf.player(name).team).log[tonumber(id)].msg.." request from "..ctf.team(ctf.player(name).team).log[tonumber(id)].team})
							ctf.post(ctf.team(ctf.player(name).team).log[tonumber(id)].team,{msg=ctf.player(name).team.." has accepted your "..ctf.team(ctf.player(name).team).log[tonumber(id)].msg.." request"})
							id = id + 1
						end
						
						table.remove(ctf.team(ctf.player(name).team).log,id)
						ctf.save()
						ctf.gui.team_board(name,ctf.player(name).team)
						return true
					end
				end
			end
		end
	end)
	
	minetest.register_on_player_receive_fields(function(player, formname, fields)
		local name = player:get_player_name()
		if formname=="ctf:flags" then
			for key, field in pairs(fields) do
				local x,y,z = string.match(key, "goto_(%d+)_(%d+)_(%d+)")
				if x and y and x then
					player:setpos({x=x,y=y,z=z})
					return true
				end			
			end
		end
	end)

	minetest.register_on_player_receive_fields(function(player, formname, fields)
		local name = player:get_player_name()
		if formname=="ctf:dip" then
			for key, field in pairs(fields) do
				local newteam = string.match(key, "team_(.+)")
				if newteam then
					ctf.gui.team_dip(name,newteam)
					return true
				end

				newteam = string.match(key, "peace_(.+)")
				if newteam and ctf.player(name) then
					local team = ctf.player(name).team

					if team then
						if ctf.diplo.get(team,newteam) == "war" then
							ctf.post(newteam,{type="request",msg="peace",team=team,mode="diplo"})
						else
							ctf.diplo.set(team,newteam,"peace")
							ctf.post(team,{msg="You have cancelled the alliance treaty with "..newteam})
							ctf.post(newteam,{msg=team.." has cancelled the alliance treaty"})
						end
					end
					
					ctf.gui.team_dip(name,team)
					return true
				end
				
				newteam = string.match(key, "war_(.+)")
				if newteam and ctf.player(name) then
					local team = ctf.player(name).team

					if team then
						ctf.diplo.set(team,newteam,"war")
						ctf.post(team,{msg="You have declared war on "..newteam})
						ctf.post(newteam,{msg=team.." has declared war on you"})
					end
					
					ctf.gui.team_dip(name,team)
					return true
				end
				
				newteam = string.match(key, "alli_(.+)")
				if newteam and ctf.player(name) then
					local team = ctf.player(name).team

					if team then
						ctf.post(newteam,{type="request",msg="alliance",team=team,mode="diplo"})
					end

					ctf.gui.team_dip(name,team)
					return true
				end
				
				newteam = string.match(key, "cancel_(.+)")
				if newteam and ctf.player(name) then
					local team = ctf.player(name).team

					if team then
						ctf.diplo.cancel_requests(team,newteam)
					end
					
					ctf.gui.team_dip(name,team)
					return true
				end
			end
		end
	end)
end  -- end of check if team guis are enabled

-- Flag interface
function ctf.gui.flag_board(name,pos)
	local flag = ctf.area.get_flag(pos)
	if not flag then
		return
	end

	local team = flag.team
	if not team then
		return
	end

	if ctf.can_mod(name,team) == false then
		if ctf.player(name) and ctf.player(name).team and ctf.player(name).team == team then
			ctf.gui.team_board(name,team)
		end
		return
	end

	local flag_name = flag.name

	if not ctf.setting("flag_names") then
		flag.name = nil
		return
	end
	
	if not ctf.setting("gui") then
		return
	end

	if not flag_name then
		flag_name = ""
	end
	
	if not ctf.gui.flag_data then
		ctf.gui.flag_data = {}
	end

	ctf.gui.flag_data[name] = {pos=pos}

	minetest.show_formspec(name, "ctf:flag_board",
		"size[6,3]"..
		"field[1,1;4,1;flag_name;Flag Name;"..flag_name.."]"..
		"button_exit[1,2;2,1;save;Save]"..
		"button_exit[3,2;2,1;delete;Delete]"
	)
end
minetest.register_on_player_receive_fields(function(player, formname, fields)
	local name = player:get_player_name()
	
	if not formname=="ctf:flag_board" then
		return false
	end

	if fields.save and fields.flag_name then
		local flag = ctf.area.get_flag(ctf.gui.flag_data[name].pos)
		if not flag then
			return false
		end

		local team = flag.team
		if not team then
			return false
		end
		
		if ctf.can_mod(name,team) == false then
			return false
		end

		local flag_name = flag.name
		if not flag_name then
			flag_name = ""
		end

		flag.name = fields.flag_name

		local msg = flag_name.." was renamed to "..fields.flag_name

		if flag_name=="" then
			msg = "A flag was named "..fields.flag_name.." at ("..ctf.gui.flag_data[name].pos.x..","..ctf.gui.flag_data[name].pos.z..")"
		end

		print(msg)
		
		ctf.post(team,{msg=msg,icon="flag_info"})

		return true
	elseif fields.delete then
		local pos = ctf.gui.flag_data[name].pos
		
		local flag = ctf.area.get_flag(ctf.gui.flag_data[name].pos)
		
		if not flag then
			print("No flag?!")
		end

		local team = flag.team
		if not team then
			return
		end
		
		if ctf.can_mod(name,team) == false then
			return false
		end
		
		ctf.area.delete_flag(team,pos)
		
		minetest.env:set_node(pos,{name="air"})
		pos.y=pos.y+1
		minetest.env:set_node(pos,{name="air"})

		return true
	end
end)
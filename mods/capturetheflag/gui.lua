cf.gui = {}

if cf.settings.team_gui and cf.settings.gui then -- check if team guis are enabled
	-- Get tab buttons
	function cf.gui.tabs(name,team)
		return (
			"button[1,0;2,1;home;About]"..
			"button[3,0;2,1;board;News]"..
			"button[5,0;2,1;diplo;Diplomacy]"..
			"button[7,0;2,1;admin;Settings]"
		)
	end
	
	-- Team interface
	function cf.gui.team_board(name,team)
		local result = ""
		local data = cf.teams[team].log
	
		if not data then
			data = {}
		end

		local amount = 0

		for i=1,#data do
			if data[i].type == "request" then
				if cf.can_mod(name,team)==true then
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

		if cf.can_mod(name,team)==true then
			result = result .. "button[4,6;2,1;clear;Clear all]"
		end

		if amount == 0 then
			result = "label[0.5,1;Welcome to the news panel]"..
				"label[0.5,1.5;News such as attacks will appear here]"
		end

		minetest.show_formspec(name, "capturetheflag:board",
			"size[10,7]"..
			cf.gui.tabs(name,team)..
			result
		)
	end

	-- Team interface
	function cf.gui.team_about(name,team)
		local result = ""
		local data = {
			"Welcome to "..team.."!",
		}
	
		local amount = 0
	
		for i=1,#data do
			amount = i
			local height = (i*0.5)+0.5
			
			if height > 5 then
				break
			end
	
			result = result .. "label[0.5,".. height ..";".. data[i] .."]"
		end
	
		minetest.show_formspec(name, "capturetheflag:home",
			"size[10,7]"..
			cf.gui.tabs(name,team)..
			result
		)
	end
	
	-- Team interface
	function cf.gui.team_dip(name,team)
		local result = ""
		local data = {}

		local amount = 0
		
		for key,value in pairs(cf.teams) do
			if key ~= team then
				table.insert(data,{
						team = key,
						state = cf.diplo.get(team,key),
						to = cf.diplo.check_requests(team,key),
						from = cf.diplo.check_requests(key,team)
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

			if cf.can_mod(name,team)==true and cf.player(name).team == team then
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
	
		minetest.show_formspec(name, "capturetheflag:dip",
			"size[10,7]"..
			cf.gui.tabs(name,team)..
			result
		)
	end
	
	-- Team interface
	function cf.gui.team_settings(name,team)
		if not team or not cf.team(team) then
			return
		end
	
		local color = ""
	
		if cf.team(team).data and cf.team(team).data.color then
			color = cf.team(team).data.color
		end
	
		local result = "field[1,2;4,1;color;Team Color;"..color.."]"..
			"button[4,6;2,1;save;Save]"
	
	
		if cf.can_mod(name,team) == false then
			result = "label[0.5,1;You do not own this team!"
		end
	
		minetest.show_formspec(name, "capturetheflag:team_settings",
			"size[10,7]"..
			cf.gui.tabs(name,team)..
			result
		)
	end
	
	minetest.register_chatcommand("team", {
		description = "Open the team console",
		func = function(name, param)
			if cf and cf.players and cf.players[name] and cf.players[name].team then
				cf.gui.team_board(name,cf.players[name].team)
			end
		end,
	})

	minetest.register_on_player_receive_fields(function(player, formname, fields)
		local name = player:get_player_name()
		if formname=="capturetheflag:board" or formname=="capturetheflag:home" or formname=="capturetheflag:dip" or formname=="capturetheflag:team_settings" then
			if fields.home then
				if cf and cf.players and cf.players[name] and cf.players[name].team then
					cf.gui.team_about(name,cf.players[name].team)
				end
				return true
			end
			if fields.board then
				if cf and cf.players and cf.players[name] and cf.players[name].team then
					cf.gui.team_board(name,cf.players[name].team)
				end
				return true
			end
			if fields.diplo then
				if cf and cf.players and cf.players[name] and cf.players[name].team then
					cf.gui.team_dip(name,cf.players[name].team)
				end
				return true
			end
			if fields.admin then
				if cf and cf.players and cf.players[name] and cf.players[name].team then
					cf.gui.team_settings(name,cf.players[name].team)
				end
				return true
			end
			if fields.clear then
				if cf and cf.players and cf.players[name] and cf.players[name].team then
					cf.team(cf.players[name].team).log = {}
					cf.save()
					cf.gui.team_board(name,cf.players[name].team)
				end
				return true
			end
			if fields.save and formname=="capturetheflag:team_settings" then
				if cf and cf.players and cf.players[name] and cf.players[name].team then
					cf.gui.team_settings(name,cf.players[name].team)
				end
				if cf and cf.team(cf.players[name].team) and cf.team(cf.players[name].team).data then
					if minetest.registered_items["capturetheflag:flag_top_"..fields.color] then
						print("Setting color...")
						cf.team(cf.players[name].team).data.color = fields.color
						cf.save()
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
		if formname=="capturetheflag:board" then
			for key, field in pairs(fields) do
				local ok, id = string.match(key, "btn_([yn])([0123456789]+)")
				if ok and id then
					if cf.player(name) and cf.player(name).team and cf.team(cf.player(name).team) then
						if ok == "y" then
							cf.diplo.set(cf.player(name).team, cf.team(cf.player(name).team).log[tonumber(id)].team, cf.team(cf.player(name).team).log[tonumber(id)].msg)
							cf.post(cf.player(name).team,{msg="You have accepted the "..cf.team(cf.player(name).team).log[tonumber(id)].msg.." request from "..cf.team(cf.player(name).team).log[tonumber(id)].team})
							cf.post(cf.team(cf.player(name).team).log[tonumber(id)].team,{msg=cf.player(name).team.." has accepted your "..cf.team(cf.player(name).team).log[tonumber(id)].msg.." request"})
							id = id + 1
						end
						
						table.remove(cf.team(cf.player(name).team).log,id)
						cf.save()
						cf.gui.team_board(name,cf.player(name).team)
						return true
					end
				end
			end
		end
	end)

	minetest.register_on_player_receive_fields(function(player, formname, fields)
		local name = player:get_player_name()
		if formname=="capturetheflag:dip" then
			for key, field in pairs(fields) do
				local newteam = string.match(key, "team_(.+)")
				if newteam then
					cf.gui.team_dip(name,newteam)
					return true
				end

				newteam = string.match(key, "peace_(.+)")
				if newteam and cf.player(name) then
					local team = cf.player(name).team

					if team then
						if cf.diplo.get(team,newteam) == "war" then
							cf.post(newteam,{type="request",msg="peace",team=team,mode="diplo"})
						else
							cf.diplo.set(team,newteam,"peace")
							cf.post(team,{msg="You have cancelled the alliance treaty with "..newteam})
							cf.post(newteam,{msg=team.." has cancelled the alliance treaty"})
						end
					end
					
					cf.gui.team_dip(name,team)
					return true
				end
				
				newteam = string.match(key, "war_(.+)")
				if newteam and cf.player(name) then
					local team = cf.player(name).team

					if team then
						cf.diplo.set(team,newteam,"war")
						cf.post(team,{msg="You have declared war on "..newteam})
						cf.post(newteam,{msg=team.." has declared war on you"})
					end
					
					cf.gui.team_dip(name,team)
					return true
				end
				
				newteam = string.match(key, "alli_(.+)")
				if newteam and cf.player(name) then
					local team = cf.player(name).team

					if team then
						cf.post(newteam,{type="request",msg="alliance",team=team,mode="diplo"})
					end

					cf.gui.team_dip(name,team)
					return true
				end
				
				newteam = string.match(key, "cancel_(.+)")
				if newteam and cf.player(name) then
					local team = cf.player(name).team

					if team then
						cf.diplo.cancel_requests(team,newteam)
					end
					
					cf.gui.team_dip(name,team)
					return true
				end
			end
		end
	end)
end  -- end of check if team guis are enabled

-- Flag interface
function cf.gui.flag_board(name,pos)
	local flag = cf.area.get_flag(pos)
	if not flag then
		return
	end

	local team = flag.team
	if not team then
		return
	end

	if cf.can_mod(name,team) == false then
		if cf.player(name) and cf.player(name).team and cf.player(name).team == team then
			cf.gui.team_board(name,team)
		end
		return
	end

	local flag_name = flag.name
	
	if not cf.settings.flag_names then
		flag.name = nil
		return
	end
	
	if not cf.settings.gui then
		return
	end

	if not flag_name then
		flag_name = ""
	end
	
	if not cf.gui.flag_data then
		cf.gui.flag_data = {}
	end

	cf.gui.flag_data[name] = {pos=pos}

	minetest.show_formspec(name, "capturetheflag:flag_board",
		"size[6,3]"..
		"field[1,1;4,1;flag_name;Flag Name;"..flag_name.."]"..
		"button_exit[1,2;2,1;save;Save]"..
		"button_exit[3,2;2,1;delete;Delete]"
	)
end
minetest.register_on_player_receive_fields(function(player, formname, fields)
	local name = player:get_player_name()
	
	if not formname=="capturetheflag:flag_board" then
		return false
	end

	if fields.save and fields.flag_name then
		local flag = cf.area.get_flag(cf.gui.flag_data[name].pos)
		if not flag then
			return false
		end

		local team = flag.team
		if not team then
			return false
		end
		
		if cf.can_mod(name,team) == false then
			return false
		end

		local flag_name = flag.name
		if not flag_name then
			flag_name = ""
		end

		flag.name = fields.flag_name

		local msg = flag_name.." was renamed to "..fields.flag_name

		if flag_name=="" then
			msg = "A flag was named "..fields.flag_name.." at ("..cf.gui.flag_data[name].pos.x..","..cf.gui.flag_data[name].pos.z..")"
		end

		print(msg)
		
		cf.post(team,{msg=msg,icon="flag_info"})

		return true
	elseif fields.delete then
		local pos = cf.gui.flag_data[name].pos

		local team = cf.area.get_flag(cf.gui.flag_data[name].pos).team
		if not team then
			return
		end
		
		if cf.can_mod(name,team) == false then
			return false
		end
		
		cf.area.delete_flag(team,pos)
		
		minetest.env:set_node(pos,{name="air"})
		pos.y=pos.y+1
		minetest.env:set_node(pos,{name="air"})

		return true
	end
end)
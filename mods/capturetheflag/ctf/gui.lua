ctf.gui = {
	tabs = {}
}

ctf.register_on_init(function()
	ctf._set("gui",                        true)
	ctf._set("gui.team",                   true)
	ctf._set("gui.team.initial",           "news")

	for name, tab in pairs(ctf.gui.tabs) do
		ctf._set("gui.tab." .. name,       true)
	end
end)

function ctf.gui.register_tab(name, title, func)
	ctf.gui.tabs[name] = {
		name  = name,
		title = title,
		func  = func
	}
end

function ctf.gui.show(name, tab, team)
	if not tab then
		tab = ctf.setting("gui.team.initial") or "news"
	end

	if not tab or not ctf.gui.tabs[tab] or not name or name == "" then
		ctf.log("gui", "Invalid tab or name given to ctf.gui.show")
		return
	end

	if not ctf.setting("gui.team") or not ctf.setting("gui") then
		return
	end

	if not team or not ctf.team(team) then
		team = ctf.player(name).team
		print(team)
	end

	if team and team ~= "" and ctf.team(team) then
		ctf.action("gui", name .. " views " .. team .. "'s " .. tab .. " page")
		ctf.gui.tabs[tab].func(name, team)
	else
		ctf.log("gui", "Invalid team given to ctf.gui.show")
	end
end

-- Get tab buttons
function ctf.gui.get_tabs(name, team)
	local result = ""
	local id = 1
	local function addtab(name,text)
		result = result .. "button["..(id*2-1)..",0;2,1;"..name..";"..text.."]"
		id = id + 1
	end

	for name, tab in pairs(ctf.gui.tabs) do
		if ctf.setting("gui.tab."..name) then
			addtab(name, tab.title)
		end
	end

	return result
end

-- Team interface
ctf.gui.register_tab("news", "News", function(name, team)
	local result = ""
	local data = ctf.teams[team].log

	if not data then
		data = {}
	end

	local amount = 0

	for i = 1, #data do
		if data[i].type == "request" then
			if ctf.can_mod(name, team) then
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
			local height = (amount*0.5) + 0.5

			if height > 5 then
				break
			end

			result = result .. "label[0.5,".. height ..";".. minetest.formspec_escape(data[i].msg) .."]"
		end
	end

	if ctf.can_mod(name, team) then
		result = result .. "button[4,6;2,1;clear;Clear all]"
	end

	if amount == 0 then
		result = "label[0.5,1;Welcome to the news panel]"..
			"label[0.5,1.5;News such as attacks will appear here]"
	end

	minetest.show_formspec(name, "ctf:news",
		"size[10,7]"..
		ctf.gui.get_tabs(name,team)..
		result)
end)

-- Team interface
ctf.gui.register_tab("diplo", "Diplomacy", function(name, team)
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

	minetest.show_formspec(name, "ctf:diplo",
		"size[10,7]"..
		ctf.gui.get_tabs(name,team)..
		result
	)
end)

-- Team interface
ctf.gui.register_tab("settings", "Settings", function(name, team)
	local color = ""

	if ctf.team(team).data and ctf.team(team).data.color then
		color = ctf.team(team).data.color
	end

	local result = "field[3,2;4,1;color;Team Color;"..color.."]"..
		"button[4,6;2,1;save;Save]"


	if ctf.can_mod(name,team) == false then
		result = "label[0.5,1;You do not own this team!"
	end

	minetest.show_formspec(name, "ctf:settings",
		"size[10,7]"..
		ctf.gui.get_tabs(name,team)..
		result
	)
end)

local function formspec_is_ctf_tab(fsname)
	for name, tab in pairs(ctf.gui.tabs) do
		if fsname == "ctf:" .. name then
			return true
		end
	end
	return false
end

minetest.register_on_player_receive_fields(function(player, formname, fields)
	local name = player:get_player_name()
	if not formspec_is_ctf_tab(formname) then
		return false
	end

	-- Do navigation
	for tname, tab in pairs(ctf.gui.tabs) do
		if fields[tname] then
			ctf.gui.show(name, tname)
			return true
		end
	end

	-- Todo: move callbacks
	-- News page
	if fields.clear then
		if ctf and ctf.players and ctf.players[name] and ctf.players[name].team then
			ctf.team(ctf.players[name].team).log = {}
			ctf.save()
			ctf.gui.show(name, "news")
		end
		return true
	end

	-- Settings page
	if fields.save and formname=="ctf:settings" then
		if ctf and ctf.players and ctf.players[name] and ctf.players[name].team then
			ctf.gui.show(name, "settings")
		end
		if ctf and ctf.team(ctf.players[name].team) and ctf.team(ctf.players[name].team).data then
			if ctf.flag_colors[fields.color] then
				ctf.team(ctf.players[name].team).data.color = fields.color
				ctf.save()
			else
				local colors = ""
				for color, code in pairs(ctf.flag_colors) do
					if color ~= "" then
						color ..= ", "
					end
					color ..= color
				end
				minetest.chat_send_player(name,"Color "..fields.color..
						" does not exist! Available: " .. colors)
			end
		end
		return true
	end
end)

minetest.register_on_player_receive_fields(function(player, formname, fields)
	local name = player:get_player_name()
	if formname=="ctf:news" then
		for key, field in pairs(fields) do
			local ok, id = string.match(key, "btn_([yn])([0123456789]+)")
			if ok and id then
				if ctf.player(name).team and ctf.team(ctf.player(name).team) then
					if ok == "y" then
						ctf.diplo.set(ctf.player(name).team, ctf.team(ctf.player(name).team).log[tonumber(id)].team, ctf.team(ctf.player(name).team).log[tonumber(id)].msg)
						ctf.post(ctf.player(name).team,{msg="You have accepted the "..ctf.team(ctf.player(name).team).log[tonumber(id)].msg.." request from "..ctf.team(ctf.player(name).team).log[tonumber(id)].team})
						ctf.post(ctf.team(ctf.player(name).team).log[tonumber(id)].team,{msg=ctf.player(name).team.." has accepted your "..ctf.team(ctf.player(name).team).log[tonumber(id)].msg.." request"})
						id = id + 1
					end

					table.remove(ctf.team(ctf.player(name).team).log,id)
					ctf.save()
					ctf.gui.show(name, "news")
					return true
				end
			end
		end
	end
end)

minetest.register_on_player_receive_fields(function(player, formname, fields)
	local name = player:get_player_name()
	if formname=="ctf:diplo" then
		for key, field in pairs(fields) do
			local newteam = string.match(key, "team_(.+)")
			if newteam then
				ctf.gui.show(name, "diplo")
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

				ctf.gui.show(name, "diplo")
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

				ctf.gui.show(name, "diplo")
				return true
			end

			newteam = string.match(key, "alli_(.+)")
			if newteam and ctf.player(name) then
				local team = ctf.player(name).team

				if team then
					ctf.post(newteam,{type="request",msg="alliance",team=team,mode="diplo"})
				end

				ctf.gui.show(name, "diplo")
				return true
			end

			newteam = string.match(key, "cancel_(.+)")
			if newteam and ctf.player(name) then
				local team = ctf.player(name).team

				if team then
					ctf.diplo.cancel_requests(team,newteam)
				end

				ctf.gui.show(name, "diplo")
				return true
			end
		end
	end
end)

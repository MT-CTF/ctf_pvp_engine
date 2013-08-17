-- Chat plus
chatplus = {
	log = true,			-- change this to true to log all chat messages
	log_file = minetest.get_worldpath().."/chatplus-log.txt",	-- default log file
	distance = minetest.setting_get("chatplus_distance"),
	log_handle = nil,	-- do not change

	
	-- Initialise Chat Plus
	init = function()
		chatplus.load()
		
		if not chatplus.players then
			chatplus.players = {}
		end
		
		chatplus._players = {}
	end,

	-- Checks that a user's namespace is ok
	poke = function(name,player)
		if not chatplus.players then
			chatplus.init()
		end

		if not chatplus.players[name] then
			chatplus.players[name] = {}
		end

		if not chatplus.players[name].ignore then
			chatplus.players[name].ignore = {}			
		end

		if not chatplus.players[name].messages then
			chatplus.players[name].messages = {}		
		end

		chatplus.players[name].enabled = true

		if player then
			if player=="end" then
				chatplus.players[name].enabled = false
				chatplus._players[name] = nil
			elseif not chatplus._players[name] then
				chatplus._players[name] = {player = player}
			end
		end

		chatplus.save()
		
		return chatplus.players[name]
	end,

	-- Outputs and sends message stream
	activate = function(name)
		if not chatplus.players[name] then
			return false
		end

		local player = chatplus.players[name]

		if not player.messages or #player.messages==0 then
			minetest.chat_send_player(name,"You have no messages")
			return false
		end

		minetest.chat_send_player(name,"("..#player.messages..") You have mail:")
		for i=1,#player.messages do
			minetest.chat_send_player(name,player.messages[i],false)
		end
		minetest.chat_send_player(name,"("..#player.messages..")",false)

		return true
	end,

	count = 0,
	
	save = function()
		print("[Chatplus] Saving data")
	
		local file = io.open(minetest.get_worldpath().."/chatplus.txt", "w")
		if file then
			file:write(minetest.serialize(chatplus.players))
			file:close()
		end
	end,
	
	load = function()
		-- Initialize the log
		if ( chatplus.log == true ) then
			chatplus.log_handle = io.open(chatplus.log_file,"a+")
			if ( chatplus.log_handle == nil ) then
				minetest.log("action","Unable to open chat plus log file: "..chatplus.log_file)
			else
				minetest.log("action","Logging chat plus to: "..chatplus.log_file)
			end	
			-- no further checking, when writing to log we will make sure chatplus.log_handle ~= nil
		end
	
		-- load saved messages
		local file = io.open(minetest.get_worldpath().."/chatplus.txt", "r")
		if file then
			local table = minetest.deserialize(file:read("*all"))
			file:close()

			if type(table) == "table" then
				chatplus.players = table
				return
			end
		end
	end,
	_handlers = {},
	register_handler = function(func,place)
		if not place then
			table.insert(chatplus._handlers,func)
		else
			table.insert(chatplus._handlers,place,func)
		end
	end
}

function chatplus.get_distance(v, w)
    return math.sqrt(
        math.pow(v.x - w.x, 2) +
        math.pow(v.y - w.y, 2) +
        math.pow(v.z - w.z, 2)
    )
end

-- Register handler caller
minetest.register_on_chat_message(function(name,msg)
	if ( chatplus.log_handle ~= nil ) then
		chatplus.log_handle:write(os.date("%m/%d/%Y %I:%M%p").." <"..name.."> "..msg.."\r\n")
		chatplus.log_handle:flush()
	end
	for key,value in pairs(chatplus.players) do
		local res = nil
		for i=1,#chatplus._handlers do
			if chatplus._handlers[i] then
				res = chatplus._handlers[i](name,key,msg)
				
				if res ~= nil then
					break
				end
			end
		end
		if (res == nil or res == true) and key~=name  then
			minetest.chat_send_player(key,"<"..name.."> "..msg,false)
		end
	end

	return true
end)

-- Register ignore
chatplus.register_handler(function(from,to,msg)
	if chatplus.players[to] and chatplus.players[to].ignore and chatplus.players[to].ignore[from]==true then
		return false
	end
	return nil
end)

if chatplus.distance then
chatplus.register_handler(function(from,to,msg)
	local from_o = minetest.get_player_by_name(from)
	local to_o = minetest.get_player_by_name(to)

	if not from_o or not to_o then
		return nil
	end

	if chatplus.distance ~= 0 and chatplus.distance ~= nil and (chatplus.get_distance(from_o:getpos(),to_o:getpos()) > tonumber(chatplus.distance)) then
		return false
	end
	return nil
end)
end

minetest.register_on_joinplayer(function(player)
	local _player = chatplus.poke(player:get_player_name(),player)

	if ( chatplus.log_handle ~= nil ) then
		chatplus.log_handle:write(os.date("%m/%d/%Y %I:%M%p").." "..player:get_player_name().." joined\r\n")
		chatplus.log_handle:flush()
	end

	if _player.messages and #_player.messages>0 then
		-- Sending chat messages immediately on join are sometimes missed or not received at all so we delay it	
		minetest.after(10,minetest.chat_send_player,player:get_player_name(),"("..#_player.messages..") You have mail! Type /inbox to recieve")	
		--minetest.chat_send_player(player:get_player_name(),"("..#_player.messages..") You have mail! Type /inbox to recieve")
	end
end)

minetest.register_on_leaveplayer(function(player)
	chatplus.poke(player:get_player_name(),"end")
	chatplus.players[player:get_player_name()].enabled = false
	if ( chatplus.log_handle ~= nil ) then
		chatplus.log_handle:write(os.date("%m/%d/%Y %I:%M%p").." "..player:get_player_name().." disconnected\r\n")
		chatplus.log_handle:flush()
	end
end)

minetest.register_globalstep(function(dtime)
	chatplus.count = chatplus.count + dtime
	if chatplus.count > 5 then
		chatplus.count = 0
		-- loop through player list
		for key,value in pairs(chatplus.players) do
			if chatplus._players and chatplus._players[key] and chatplus._players[key].player and value and value.messages and chatplus._players[key].player.hud_add and chatplus._players[key].lastcount ~= #value.messages then				
				if chatplus._players[key].msgicon then
					chatplus._players[key].player:hud_remove(chatplus._players[key].msgicon)
				end

				if chatplus._players[key].msgicon2 then
					chatplus._players[key].player:hud_remove(chatplus._players[key].msgicon2)
				end

				if #value.messages>0 then
					chatplus._players[key].msgicon = chatplus._players[key].player:hud_add({
						hud_elem_type = "image",
						name = "MailIcon",
						position = {x=0.52, y=0.52},
						text="chatplus_mail.png",
						scale = {x=1,y=1},
						alignment = {x=0.5, y=0.5},
					})
					chatplus._players[key].msgicon2 = chatplus._players[key].player:hud_add({
						hud_elem_type = "text",
						name = "MailText",
						position = {x=0.55, y=0.52},
						text=#value.messages,
						scale = {x=1,y=1},
						alignment = {x=0.5, y=0.5},
					})					
				end
				chatplus._players[key].lastcount = #value.messages
			end
		end
	end
end)

minetest.register_chatcommand("ignore", {
	params = "name",
	description = "ignore: Ignore a player",
	func = function(name, param)
		chatplus.poke(name)
		if not chatplus.players[name].ignore[param]==true then
			chatplus.players[name].ignore[param]=true
			minetest.chat_send_player(name,param.." has been ignored")
			chatplus.save()
		else
			minetest.chat_send_player(name,"Player "..param.." is already ignored.")
		end
	end,
})

minetest.register_chatcommand("unignore", {
	params = "name",
	description = "unignore: Unignore a player",
	func = function(name, param)
		chatplus.poke(name)
		if chatplus.players[name].ignore[param]==true then
			chatplus.players[name].ignore[param]=false
			minetest.chat_send_player(name,param.." has been unignored")
			chatplus.save()
		else
			minetest.chat_send_player(name,"Player "..param.." is already unignored.")
		end
	end,
})

minetest.register_chatcommand("inbox", {
	params = "clear?",
	description = "inbox: print the items in your inbox",
	func = function(name, param)
		if param == "clear" then
			local player = chatplus.poke(name)
			player.messages = {}
			chatplus.save()
			minetest.chat_send_player(name,"Inbox cleared")
		else
			chatplus.activate(name)
		end
	end,
})

minetest.register_chatcommand("mail", {
	params = "name msg",
	description = "mail: add a message to a player's inbox",
	func = function(name, param)
		chatplus.poke(name)
		local to, msg = string.match(param, "([%a%d_]+) (.+)")
		
		if not to or not msg then
			minetest.chat_send_player(name,"mail: <playername> <msg>")
			return
		end

		print("To: "..to)
		print("From: "..name)
		print("MSG: "..msg)
		
		if chatplus.players[to] then
			table.insert(chatplus.players[to].messages,"mail from <"..name..">: "..msg)
			minetest.chat_send_player(name,"Message sent")
			chatplus.save()
		else
			minetest.chat_send_player(name,"Player "..to.." does not exist")
		end
	end,
})

chatplus.init()
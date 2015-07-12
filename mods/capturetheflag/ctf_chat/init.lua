function init()
	-- Settings: Chat
	ctf._set("team_channel",               true)
	ctf._set("global_channel",             true)
end
init()

local function team_console_help(name)
	minetest.chat_send_player(name,"Try:", false)
	minetest.chat_send_player(name,"/team - show team panel", false)
	minetest.chat_send_player(name,"/team all - list all teams", false)
	minetest.chat_send_player(name,"/team name - show details about team 'name'", false)
	minetest.chat_send_player(name,"/team player name - get which team 'player' is in", false)

	local privs = minetest.get_player_privs(name)
	if privs and privs.team == true then
		minetest.chat_send_player(name,"/team add name - add a team called name (admin only)", false)
		minetest.chat_send_player(name,"/team join player team - add 'player' to team 'team' (admin only)", false)
	end
end

minetest.register_chatcommand("team", {
	description = "Open the team console, or run team command (see /team help)",
	func = function(name, param)
		local test = string.match(param,"^player ([%a%d_]+)")
		local create = string.match(param,"^add ([%a%d_]+)")
		local tplayer,tteam = string.match(param,"^join ([%a%d_]+) ([%a%d_]+)")
		if test then
			if ctf.player(test) then
				if ctf.player(test).team then
					if ctf.player(test).auth then
						minetest.chat_send_player(name,test.." is in team "..ctf.player(test).team.." (team owner)",false)
					else
						minetest.chat_send_player(name,test.." is in team "..ctf.player(test).team,false)
					end
				else
					minetest.chat_send_player(name,test.." is not in a team",false)
				end
			else
				minetest.chat_send_player(name,"Player '"..test.."' could not be found",false)
			end
		elseif create then
			local privs = minetest.get_player_privs(name)
			if privs and privs.team == true then
				if (
					string.match(create,"([%a%b_]-)")
					and ctf.team({name=create,add_team=true})
					and create ~= ""
					and create ~= nil
				) then
					minetest.chat_send_player(name, "Added team '"..create.."'",false)
				else
					minetest.chat_send_player(name, "Error adding team '"..create.."'",false)
				end
			else
				minetest.chat_send_player(name, "You can not do this!",false)
			end
		elseif param == "all" then
			minetest.chat_send_player(name, "Teams:",false)
			for k,v in pairs(ctf.teams) do
				if v and v.players then
					local numPlayers = ctf.count_players_in_team(k)
					local numFlags = 0
					for k, v in pairs(v.flags) do
						numFlags = numFlags + 1
					end
					minetest.chat_send_player(name, ">> "..k.." ("..numFlags.." flags, "..numPlayers.." players)")
				end
			end
		elseif ctf.team(param) then
			minetest.chat_send_player(name,"Team "..param..":",false)
			local count = 0
			for _,value in pairs(ctf.team(param).players) do
				count = count + 1
				if value.aut == true then
					minetest.chat_send_player(name,count..">> "..value.name.." (team owner)",false)
				else
					minetest.chat_send_player(name,count..">> "..value.name,false)
				end
			end
		elseif tplayer and tteam then
			minetest.chat_send_player(name,"joining '"..tplayer.."' to team '"..tteam.."'",false)
			local privs = minetest.get_player_privs(name)
			if privs and privs.team == true then
				local player = ctf.player(tplayer)

				if not player then
					player = {name=tplayer}
				end

				if ctf.add_user(tteam,tplayer) == true then
					minetest.chat_send_all(tplayer.." has joined team "..tteam)
				end
			else
				minetest.chat_send_player(name, "You can not do this!")
			end
		elseif param=="help" then
			team_console_help(name)
		else
			if param~="" and param~= nil then
				minetest.chat_send_player(name,"'"..param.."' is an invalid parameter to /team",false)
				team_console_help(name)
			end
			if (
				ctf and
				ctf.players and
				ctf.players[name] and
				ctf.players[name].team and
				ctf.setting("gui")
			) then
				minetest.chat_send_player(name, "Showing the Team GUI")
				if ctf.setting("team_gui_initial") == "news" and ctf.setting("news_gui") then
					ctf.gui.team_board(name,ctf.players[name].team)
				elseif ctf.setting("team_gui_initial") == "flags" and ctf.setting("flag_teleport_gui") then
					ctf.gui.team_flags(name,ctf.players[name].team)
				elseif ctf.setting("team_gui_initial") == "diplo" and ctf.setting("diplomacy") then
					ctf.gui.team_dip(name,ctf.players[name].team)
				elseif ctf.setting("team_gui_initial") == "admin" then
					ctf.gui.team_settings(name,ctf.players[name].team)
				elseif ctf.setting("news_gui") then
					ctf.gui.team_board(name,ctf.players[name].team)
				end
			end
		end
	end,
})

minetest.register_chatcommand("join", {
	params = "team name",
	description = "Add to team",
	func = function(name, param)
		ctf.join(name, param, false)
	end,
})
minetest.register_chatcommand("list_teams", {
	params = "",
	description = "List all available teams",
	func = function(name, param)
		minetest.chat_send_player(name, "This command will be made obsolete! Use '/team all' instead!",false)
		minetest.chat_send_player(name, "Teams:")
		for k,v in pairs(ctf.teams) do
			if v and v.players then
				local numItems = 0
				for k,v in pairs(v.players) do
				    numItems = numItems + 1
				end
				local numItems2 = 0
				for k,v in pairs(v.flags) do
				    numItems2 = numItems2 + 1
				end
				minetest.chat_send_player(name, ">> "..k.." ("..numItems2.." flags, "..numItems.." players)",false)
			end
		end
	end,
})

minetest.register_chatcommand("ctf", {
	description = "Do admin cleaning stuff",
	privs = {ctf_admin=true},
	func = function(name, param)
		ctf.clean_player_lists()
		ctf.collect_claimed()
		minetest.chat_send_player(name, "CTF cleaned!")
	end,
})

minetest.register_chatcommand("reload_ctf", {
	description = "reload the ctf main frame and get settings",
	privs = {team=true},
	func = function(name, param)
		ctf.save()
		ctf.init()
		minetest.chat_send_player(name, "CTF core reloaded!")
	end
})

minetest.register_chatcommand("team_owner", {
	params = "player name",
	description = "Make player team owner",
	privs = {team=true},
	func = function(name, param)
		if ctf and ctf.players and ctf.player(param) and ctf.player(param).team and ctf.team(ctf.player(param).team) then
			if ctf.player(param).auth == true then
				ctf.player(param).auth = false
				minetest.chat_send_player(name, param.." was downgraded from team admin status",false)
			else
				ctf.player(param).auth = true
				minetest.chat_send_player(name, param.." was upgraded to an admin of "..ctf.player(name).team,false)
			end
			ctf.save()
		else
			minetest.chat_send_player(name, "Unable to do that :/ "..param.." does not exist, or is not part of a valid team.",false)
		end
	end,
})

minetest.register_chatcommand("all", {
	params = "msg",
	description = "Send a message on the global channel",
	func = function(name, param)
		if not ctf.setting("global_channel") then
			minetest.chat_send_player(name,"The global channel is disabled",false)
			return
		end

		if ctf.player(name) and ctf.player(name).team then
			minetest.chat_send_all(ctf.player(name).team.." <"..name.."> "..param)
		else
			minetest.chat_send_all("GLOBAL <"..name.."> "..param)
		end

	end,
})

minetest.register_chatcommand("post", {
	params = "message",
	description = "Post a message on your team's message board",
	func = function(name, param)

		if ctf and ctf.players and ctf.players[name] and ctf.players[name].team and ctf.teams[ctf.players[name].team] then
			if not ctf.player(name).auth then
				minetest.chat_send_player(name, "You do not own that team")
			end

			if not ctf.teams[ctf.players[name].team].log then
				ctf.teams[ctf.players[name].team].log = {}
			end

			table.insert(ctf.teams[ctf.players[name].team].log,{msg=param})

			minetest.chat_send_player(name, "Posted: "..param)
		else
			minetest.chat_send_player(name, "Could not post message")
		end
	end,
})

-- Chat plus stuff
if chatplus then
	chatplus.register_handler(function(from,to,msg)
		if not ctf.setting("team_channel") then
			return nil
		end

		local fromp = ctf.player(from)
		local top = ctf.player(to)

		if not fromp then
			if not ctf.setting("global_channel") then
				minetest.chat_send_player(from,"You are not yet part of a team, so you have no mates to send to",false)
			else
				minetest.chat_send_player(to,"GLOBAL <"..from.."> "..msg,false)
			end
			return false
		end

		if not top then
			return false
		end

		return (fromp.team == top.team)
	end)
end

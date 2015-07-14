ctf.register_on_init(function()
	ctf.log("chat", "Initialising...")

	-- Settings: Chat
	ctf._set("chat.team_channel",          true)
	ctf._set("chat.global_channel",        true)
	ctf._set("chat.default",               "global")
end)

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
			ctf.list_teams(name)
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
				ctf.gui.show(name)
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

minetest.register_chatcommand("ctf_clean", {
	description = "Do admin cleaning stuff",
	privs = {ctf_admin=true},
	func = function(name, param)
		ctf.clean_player_lists()
		if ctf_flag.collect_claimed then
			ctf_flag.collect_claimed()
		end
		minetest.chat_send_player(name, "CTF cleaned!")
	end,
})

minetest.register_chatcommand("ctf_reset", {
	description = "Delete all CTF saved states and start again.",
	privs = {ctf_admin=true},
	func = function(name, param)
		minetest.chat_send_all("The CTF core was reset. All team memberships," ..
				"flags, land ownerships etc have been deleted.")
		ctf.reset()
	end,
})

minetest.register_chatcommand("ctf_reload", {
	description = "reload the ctf main frame and get settings",
	privs = {ctf_admin=true},
	func = function(name, param)
		ctf.needs_save = true
		ctf.init()
		minetest.chat_send_player(name, "CTF core reloaded!")
	end
})

minetest.register_chatcommand("team_owner", {
	params = "player name",
	description = "Make player team owner",
	privs = {ctf_admin=true},
	func = function(name, param)
		if ctf and ctf.players and ctf.player(param) and ctf.player(param).team and ctf.team(ctf.player(param).team) then
			if ctf.player(param).auth == true then
				ctf.player(param).auth = false
				minetest.chat_send_player(name, param.." was downgraded from team admin status",false)
			else
				ctf.player(param).auth = true
				minetest.chat_send_player(name, param.." was upgraded to an admin of "..ctf.player(name).team,false)
			end
			ctf.needs_save = true
		else
			minetest.chat_send_player(name, "Unable to do that :/ "..param.." does not exist, or is not part of a valid team.",false)
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

minetest.register_chatcommand("all", {
	params = "msg",
	description = "Send a message on the global channel",
	func = function(name, param)
		if not ctf.setting("chat.global_channel") then
			minetest.chat_send_player(name, "The global channel is disabled")
			return
		end

		if ctf.player(name) and ctf.player(name).team then
			minetest.chat_send_all(ctf.player(name).team .. " <" ..
					name .. "> " .. param)
		else
			minetest.chat_send_all("<"..name.."> "..param)
		end
	end
})

minetest.register_chatcommand("t", {
	params = "msg",
	description = "Send a message on the team channel",
	func = function(name, param)
		if not ctf.setting("chat.team_channel") then
			minetest.chat_send_player(name, "The team channel is disabled.")
			return
		end

		if ctf.player(name).team then
			local team = ctf.team(ctf.player(name).team)
			if team then
				for username, to in pairs(team.players) do
					minetest.chat_send_player(username,
							"<" .. name .. "> ** " .. param .. " **")
				end
			end
		else
			minetest.chat_send_player(name,
					"You're not in a team, so you have no team to talk to.")
		end
	end
})

-- Chat plus stuff
if chatplus then
	chatplus.register_handler(function(from, to, msg)
		if not ctf.setting("chat.team_channel") or
				ctf.setting("chat.default") ~= "team" then
			-- Send to global
			return nil
		end

		-- Send to team
		local fromp = ctf.player(from)
		local top = ctf.player(to)

		if not fromp then
			if not ctf.setting("chat.global_channel") then
				-- Send to global
				return nil
			else
				-- Global channel is disabled
				minetest.chat_send_player(from,
						"You are not yet part of a team! Join one so you can chat to people.",
						false)
				return false
			end
		end

		if top.team == fromp.team then
			minetest.chat_send_player(to, "<" .. from .. "> ** " .. msg .. " **")
		end
		return false
	end)
end

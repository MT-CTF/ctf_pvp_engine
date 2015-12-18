ctf.register_on_init(function()
	ctf.log("chat", "Initialising...")

	-- Settings: Chat
	ctf._set("chat.team_channel",          true)
	ctf._set("chat.global_channel",        true)
	ctf._set("chat.default",               "global")
end)

local function team_console_help(name)
	minetest.chat_send_player(name, "Try:")
	minetest.chat_send_player(name, "/team - show team panel")
	minetest.chat_send_player(name, "/team all - list all teams")
	minetest.chat_send_player(name, "/team <team> - show details about team 'name'")
	minetest.chat_send_player(name, "/team <name> - get which team 'player' is in")
	minetest.chat_send_player(name, "/team player <name> - get which team 'player' is in")

	local privs = minetest.get_player_privs(name)
	if privs and privs.ctf_admin == true then
		minetest.chat_send_player(name, "/team add <team> - add a team called name (ctf_admin only)")
		minetest.chat_send_player(name, "/team remove <team> - add a team called name (ctf_admin only)")
	end
	if privs and privs.ctf_team_mgr == true then
		minetest.chat_send_player(name, "/team join <name> <team> - add 'player' to team 'team' (ctf_team_mgr only)")
		minetest.chat_send_player(name, "/team removeply <name> - add 'player' to team 'team' (ctf_team_mgr only)")
	end
end

minetest.register_chatcommand("team", {
	description = "Open the team console, or run team command (see /team help)",
	func = function(name, param)
		local test   = string.match(param,"^player ([%a%d_-]+)")
		local create = string.match(param,"^add ([%a%d_-]+)")
		local remove = string.match(param,"^remove ([%a%d_-]+)")
		local j_name, j_tname = string.match(param,"^join ([%a%d_-]+) ([%a%d_]+)")
		local l_name = string.match(param,"^removeplr ([%a%d_-]+)")
		if create then
			local privs = minetest.get_player_privs(name)
			if privs and privs.ctf_admin == true then
				if (
					string.match(create, "([%a%b_]-)")
					and create ~= ""
					and create ~= nil
					and ctf.team({name=create, add_team=true})
				) then
					return true, "Added team '"..create.."'"
				else
					return false, "Error adding team '"..create.."'"
				end
			else
				return false, "You are not a ctf_admin!"
			end
		elseif remove then
			local privs = minetest.get_player_privs(name)
			if privs and privs.ctf_admin == true then
				if ctf.remove_team(remove) then
					return true, "Removed team '" .. remove .. "'"
				else
					return false, "Error removing team '" .. remove .. "'"
				end
			else
				return false, "You are not a ctf_admin!"
			end
		elseif param == "all" then
			ctf.list_teams(name)
		elseif ctf.team(param) then
			minetest.chat_send_player(name, "Team "..param..":")
			local count = 0
			for _,value in pairs(ctf.team(param).players) do
				count = count + 1
				if value.auth == true then
					minetest.chat_send_player(name, count .. ">> " .. value.name
							.. " (team owner)")
				else
					minetest.chat_send_player(name, count .. ">> " .. value.name)
				end
			end
		elseif ctf.player_or_nil(param) or test then
			if not test then
				test = param
			end
			if ctf.player(test).team then
				if ctf.player(test).auth then
					return true, test ..
							" is in team " .. ctf.player(test).team.." (team owner)"
				else
					return true, test ..
							" is in team " .. ctf.player(test).team
				end
			else
				return true, test.." is not in a team"
			end
		elseif j_name and j_tname then
			local privs = minetest.get_player_privs(name)
			if privs and privs.ctf_team_mgr == true then
				if ctf.join(j_name, j_tname, true, name) then
					return true, "Successfully added " .. j_name .. " to " .. j_tname
				else
					return false, "Failed to add " .. j_name .. " to " .. j_tname
				end
			else
				return true, "You are not a ctf_team_mgr!"
			end
		elseif l_name then
			local privs = minetest.get_player_privs(name)
			if privs and privs.ctf_team_mgr == true then
				if ctf.remove_player(l_name) then
					return true, "Removed player " .. l_name
				else
					return false, "Failed to remove player."
				end
			else
				return false, "You are not a ctf_team_mgr!"
			end
		elseif param=="help" then
			team_console_help(name)
		else
			if param~="" and param~= nil then
				minetest.chat_send_player(name, "'"..param.."' is an invalid parameter to /team")
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
		if ctf.join(name, param, false, name) then
			return true, "Joined team " .. param .. "!"
		else
			return false, "Failed to join team!"
		end
	end
})

minetest.register_chatcommand("ctf_clean", {
	description = "Do admin cleaning stuff",
	privs = {ctf_admin=true},
	func = function(name, param)
		ctf.log("chat", "Cleaning CTF...")
		ctf.clean_player_lists()
		if ctf_flag and ctf_flag.assert_flags then
			ctf_flag.assert_flags()
		end
		return true, "CTF cleaned!"
	end
})

minetest.register_chatcommand("ctf_reset", {
	description = "Delete all CTF saved states and start again.",
	privs = {ctf_admin=true},
	func = function(name, param)
		minetest.chat_send_all("The CTF core was reset by the admin. All team memberships," ..
				"flags, land ownerships etc have been deleted.")
		ctf.reset()
		return true, "Reset CTF core."
	end,
})

minetest.register_chatcommand("ctf_reload", {
	description = "reload the ctf main frame and get settings",
	privs = {ctf_admin=true},
	func = function(name, param)
		ctf.needs_save = true
		ctf.init()
		return true, "CTF core reloaded!"
	end
})

minetest.register_chatcommand("ctf_ls", {
	description = "ctf: list settings",
	privs = {ctf_admin=true},
	func = function(name, param)
		minetest.chat_send_player(name, "Settings:")
		for set, def in orderedPairs(ctf._defsettings) do
			minetest.chat_send_player(name, " - " .. set .. ": " .. dump(ctf.setting(set)))
			print("\"" .. set .. "\"   " .. dump(ctf.setting(set)))
		end
		return true
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
				return true, param.." was downgraded from team admin status"
			else
				ctf.player(param).auth = true
				return true, param.." was upgraded to an admin of "..ctf.player(name).team
			end
			ctf.needs_save = true
		else
			return false, "Unable to do that :/ "..param.." does not exist, or is not part of a valid team."
		end
	end
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

		if ctf.player(name).team then
			local tosend = ctf.player(name).team ..
				" <" .. name .. "> " .. param
			minetest.chat_send_all(tosend)
			if minetest.global_exists("chatplus") then
				chatplus.log(tosend)
			end
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

		local tname = ctf.player(name).team
		local team = ctf.team(tname)
		if team then
			minetest.log("action", tname .. "<" .. name .. "> ** ".. param .. " **")
			if minetest.global_exists("chatplus") then
				chatplus.log(tname .. "<" .. name .. "> ** ".. param .. " **")
			end
			for username, to in pairs(team.players) do
				minetest.chat_send_player(username,
						tname .. "<" .. name .. "> ** " .. param .. " **")
			end
		else
			minetest.chat_send_player(name,
					"You're not in a team, so you have no team to talk to.")
		end
	end
})

-- Chat plus stuff
if minetest.global_exists("chatplus") then
	function chatplus.log_message(from, msg)
		local tname = ctf.player(from).team or ""
		chatplus.log(tname .. "<" .. from .. "> " .. msg)
	end

	chatplus.register_handler(function(from, to, msg)
		if not ctf.setting("chat.team_channel") then
			-- Send to global
			return nil
		end

		if ctf.setting("chat.default") ~= "team" then
			if ctf.player(from).team then
				minetest.chat_send_player(to, ctf.player(from).team ..
					"<" .. from .. "> " .. msg)
				return false
			else
				return nil
			end
		end

		-- Send to team
		local fromp = ctf.player(from)
		local top = ctf.player(to)

		if not fromp.team then
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

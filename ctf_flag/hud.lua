-- TODO: delete flags if they are removed (ctf.next, or captured)
ctf.hud.register_part(function(player, name, tplayer)
	if ctf.setting("flag.waypoints") then
		for tname, team in pairs(ctf.teams) do
			for _, flag in pairs(team.flags) do
				local hud = "ctf:hud_" .. flag.x .. "_" .. flag.y .. "_" .. flag.z
				local flag_name = flag.name or tname .. "'s base"
				local color = ctf.flag_colors[team.data.color]
				if not color then
					color = "0x000000"
				end
				if not ctf.hud:exists(player, hud) then
					ctf.hud:add(player, hud, {
						hud_elem_type = "waypoint",
						name = flag_name,
						number = color,
						world_pos = {
							x = flag.x,
							y = flag.y,
							z = flag.z
						}
					})
				end
			end
		end
	end
end)

ctf.hud.register_part(function(player, name, tplayer)
	-- Check all flags
	local alert = "Punch the enemy flag! Protect your flag!"
	local color = "0xFFFFFF"
	local claimed = ctf_flag.collect_claimed()
	for _, flag in pairs(claimed) do
		if flag.claimed.player == name then
			alert = "You've got the flag! Run back and punch your flag!"
			color = "0xFF0000"
			break
		elseif flag.team == tplayer.team then
			alert = "Kill " .. flag.claimed.player .. ", they have your flag!"
			color = "0xFF0000"
			break
		else
			alert = "Protect " .. flag.claimed.player .. ", he's got the enemy flag!"
			color = "0xFF0000"
		end
	end

	-- Display alert
	if alert then
		if ctf.hud:exists(player, "ctf:hud_team_alert") then
			ctf.hud:change(player, "ctf:hud_team_alert", "text", alert)
			ctf.hud:change(player, "ctf:hud_team_alert", "number", color)
		else
			ctf.hud:add(player, "ctf:hud_team_alert", {
				hud_elem_type = "text",
				position      = {x = 1, y = 0},
				scale         = {x = 100, y = 100},
				text          = alert,
				number        = color,
				offset        = {x = -10, y = 50},
				alignment     = {x = -1, y = 0}
			})
		end
	else
		ctf.hud:remove(player, "ctf:hud_team_alert")
	end
end)

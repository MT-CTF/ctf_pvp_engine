ctf.register_on_init(function()
	ctf._set("players_can_change_team",    true)
	ctf._set("endgame",                    true)
	ctf._set("endgame.break_alliances",    true)
end)

ctf_flag.register_on_flag_capture(function(team, flag)

end)

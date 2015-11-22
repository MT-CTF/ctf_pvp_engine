ctf.hud.register_part(function(player, name, tplayer)
	local text_color = ctf.team(tplayer.team).data.color
	local color = ctf.flag_colors[text_color]
	if not color then
		color = "0x000000"
	end

	if ctf.setting("colors.nametag") then
		player:set_nametag_attributes({ color = "0xFF" .. string.sub(color, 3) })
	end

	if ctf.setting("colors.skins") and text_color and color then
		player:set_properties({
			textures = {"ctf_colors_skin_" .. text_color .. ".png"},
		})
	end

	if not ctf.hud:exists(player, "ctf:hud_team") then
		ctf.hud:add(player, "ctf:hud_team", {
			hud_elem_type = "text",
			position      = {x = 1, y = 0},
			scale         = {x = 100, y = 100},
			text          = "Team " .. tplayer.team,
			number        = color,
			offset        = {x = -20, y = 20},
			alignment     = {x = -1, y = 0}
		})
	else
		ctf.hud:change(player, "ctf:hud_team", "text", "Team " .. tplayer.team)
		ctf.hud:change(player, "ctf:hud_team", "number", color)
	end
end)

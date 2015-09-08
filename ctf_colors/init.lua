ctf.flag_colors = {
	red    = "0xFF4444",
	cyan   = "0x00FFFF",
	blue   = "0x4466FF",
	purple = "0x800080",
	yellow = "0xFFFF00",
	green  = "0x00FF00",
	pink   = "0xFF00FF",
	silver = "0xC0C0C0",
	gray   = "0x808080",
	black  = "0x000000",
	orange = "0xFFA500",
	gold   = "0x808000"
}

ctf.register_on_init(function()
	ctf.log("colors", "Initialising...")
	ctf._set("colors.skins",               false)
	ctf._set("colors.nametag",             true)
end)

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
			text          = tplayer.team,
			number        = color,
			offset        = {x = -20, y = 20},
			alignment     = {x = -1, y = 0}
		})
	else
		ctf.hud:change(player, "ctf:hud_team", "text", tplayer.team)
		ctf.hud:change(player, "ctf:hud_team", "number", color)
	end
end)

ctf.gui.register_tab("settings", "Settings", function(name, team)
	local color = ""
	if ctf.team(team).data.color then
		color = ctf.team(team).data.color
	end

	local result = "field[3,2;4,1;color;Team Color;" .. color .. "]" ..
		"button[4,6;2,1;save;Save]"


	if not ctf.can_mod(name,team) then
		result = "label[0.5,1;You do not own this team!"
	end

	minetest.show_formspec(name, "ctf:settings",
		"size[10,7]" ..
		ctf.gui.get_tabs(name, team) ..
		result
	)
end)

minetest.register_on_player_receive_fields(function(player, formname, fields)
	if formname ~= "ctf:settings" then
		return false
	end

	-- Settings page
	if fields.save then
		ctf.gui.show(name, "settings")

		if ctf.flag_colors[fields.color] then
			team.data.color = fields.color
			ctf.needs_save = true
		else
			local colors = ""
			for color, code in pairs(ctf.flag_colors) do
				if colors ~= "" then
					colors = colors .. ", "
				end
				colors = colors .. color
			end
			minetest.chat_send_player(name, "Color " .. fields.color ..
					" does not exist! Available: " .. colors)
		end

		return true
	end
end)

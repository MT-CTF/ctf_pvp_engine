function ctf_colors.get_color(name, tplayer)
	local tcolor_text = ctf.team(tplayer.team).data.color
	local tcolor_hex = ctf.flag_colors[tcolor_text]
	if not tcolor_hex then
		tcolor_hex = "0x000000"
	end

	return tcolor_text, tcolor_hex
end

function ctf_colors.get_nametag_color(name, tplayer, tcolor_text, tcolor_hex)
	if ctf.setting("colors.nametag.tcolor") then
		return "0xFF" .. string.sub(tcolor_hex, 3)
	else
		return "0xFFFFFFFF"
	end
end

function ctf_colors.update(player, name, tplayer)
	if not player then
		player = minetest.get_player_by_name(name)
	end

	local tcolor_text, tcolor_hex = ctf_colors.get_color(name, tplayer)

	if ctf.setting("colors.nametag") then
		player:set_nametag_attributes({
			color = ctf_colors.get_nametag_color(name, tplayer, tcolor_text, tcolor_hex) })
	end

	if ctf.setting("colors.skins") and tcolor_text and tcolor_hex then
		if minetest.global_exists("armor") then
			-- TODO: how should support for skin mods be done?
			armor.textures[name].skin = "ctf_colors_skin_" .. tcolor_text .. ".png"
			armor:update_player_visuals(player)
		else
			player:set_properties({
				textures = {"ctf_colors_skin_" .. tcolor_text .. ".png"}
			})
		end
	end

	if not ctf.hud:exists(player, "ctf:hud_team") then
		ctf.hud:add(player, "ctf:hud_team", {
			hud_elem_type = "text",
			position      = {x = 1, y = 0},
			scale         = {x = 100, y = 100},
			text          = "Team " .. tplayer.team,
			number        = tcolor_hex,
			offset        = {x = -20, y = 20},
			alignment     = {x = -1, y = 0}
		})
	else
		ctf.hud:change(player, "ctf:hud_team", "text", "Team " .. tplayer.team)
		ctf.hud:change(player, "ctf:hud_team", "number", tcolor_hex)
	end
end


ctf.hud.register_part(ctf_colors.update)

--[[if minetest.global_exists("armor") and armor.get_player_skin then
	print("3d_armor detected!")
	local old = armor.get_player_skin
	function armor.get_player_skin(self, name)
		local player = ctf.player(name)
		local team = ctf.team(player.team)
		if team and team.data.color and ctf.flag_colors[team.data.color] then
			print("Return ctf_colors_skin_" .. team.data.color .. ".png")
			return "ctf_colors_skin_" .. team.data.color .. ".png"
		end
		print("ctf_colors -!- Reverting to default armor skin")

		return old(self, name)
	end
end]]

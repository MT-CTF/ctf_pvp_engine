-- CAPTURE THE FLAG
--	by Andrew "rubenwardy" Ward
-----------------------------------------

ctf = {}

-- Fix for https://github.com/minetest/minetest/issues/2383
local csa = minetest.chat_send_all
function minetest.chat_send_all(msg)
	minetest.after(0, function()
		csa(msg)
	end)
end

-- Privs
minetest.register_privilege("team", {
	description = "Team manager",
})

minetest.register_privilege("ctf_admin", {
	description = "Can create teams, manage players, assign team owners.",
})

-- Colors
ctf.flag_colors = {
	red = "0xFF0000",
	cyan = "0x00FFFF",
	blue  = "0x0000FF",
	purple = "0x800080",
	yellow = "0xFFFF00",
	green = "0x00FF00",
	pink = "0xFF00FF",
	silver = "0xC0C0C0",
	gray = "0x808080",
	black = "0x000000",
	orange = "0xFFA500",
	gold = "0x808000"
}

-- Modules
dofile(minetest.get_modpath("ctf").."/core.lua")
dofile(minetest.get_modpath("ctf").."/teams.lua")
dofile(minetest.get_modpath("ctf").."/diplomacy.lua")
dofile(minetest.get_modpath("ctf").."/gui.lua")
dofile(minetest.get_modpath("ctf").."/hud.lua")

-- Init
ctf.init()
ctf.clean_player_lists()

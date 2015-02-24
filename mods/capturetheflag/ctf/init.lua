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

-- Modules
dofile(minetest.get_modpath("ctf").."/core.lua")
dofile(minetest.get_modpath("ctf").."/diplomacy.lua")
dofile(minetest.get_modpath("ctf").."/area.lua")
dofile(minetest.get_modpath("ctf").."/flag.lua")
dofile(minetest.get_modpath("ctf").."/cli.lua")
dofile(minetest.get_modpath("ctf").."/gui.lua")
dofile(minetest.get_modpath("ctf").."/hud.lua")

-- Init
ctf.init()
ctf.clean_player_lists()
ctf.collect_claimed()

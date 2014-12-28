-- CAPTURE THE FLAG
--	by Andrew "rubenwardy" Ward
-----------------------------------------

ctf = {}

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

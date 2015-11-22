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

dofile(minetest.get_modpath("ctf_colors") .. "/hud.lua")
dofile(minetest.get_modpath("ctf_colors") .. "/gui.lua")

-- CAPTURE THE FLAG
--	by Andrew "rubenwardy" Ward
-----------------------------------------

cf = {}

-- Helpers
v3={}
function v3.distance(v, w)
    return math.sqrt(
        math.pow(v.x - w.x, 2) +
        math.pow(v.y - w.y, 2) +
        math.pow(v.z - w.z, 2)
    )
end
function v3.get_direction(pos1,pos2)

	local x_raw = pos2.x -pos1.x
	local y_raw = pos2.y -pos1.y
	local z_raw = pos2.z -pos1.z


	local x_abs = math.abs(x_raw)
	local y_abs = math.abs(y_raw)
	local z_abs = math.abs(z_raw)

	if 	x_abs >= y_abs and
		x_abs >= z_abs then

		y_raw = y_raw * (1/x_abs)
		z_raw = z_raw * (1/x_abs)

		x_raw = x_raw/x_abs

	end

	if 	y_abs >= x_abs and
		y_abs >= z_abs then


		x_raw = x_raw * (1/y_abs)
		z_raw = z_raw * (1/y_abs)

		y_raw = y_raw/y_abs

	end

	if 	z_abs >= y_abs and
		z_abs >= x_abs then

		x_raw = x_raw * (1/z_abs)
		y_raw = y_raw * (1/z_abs)

		z_raw = z_raw/z_abs

	end

	return {x=x_raw,y=y_raw,z=z_raw}
end

-- Load the core
dofile(minetest.get_modpath("ctf").."/core.lua")
cf.init()

-- Modules
dofile(minetest.get_modpath("ctf").."/diplomacy.lua")
dofile(minetest.get_modpath("ctf").."/area.lua")
dofile(minetest.get_modpath("ctf").."/gui.lua")
dofile(minetest.get_modpath("ctf").."/cli.lua")
dofile(minetest.get_modpath("ctf").."/flag.lua")

-- Init
cf.clean_player_lists()
cf.collect_claimed()

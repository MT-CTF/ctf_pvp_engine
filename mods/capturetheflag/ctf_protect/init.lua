-- This mod is used to protect nodes in the capture the flag game
local old_is_protected = minetest.is_protected

function minetest.is_protected(pos, name)
	local team = ctf.area.get_area(pos)

	if not team then
		return old_is_protected(pos, name)
	end

	if ctf.players and ctf.player(name) and ctf.player(name).team then
		if ctf.player(name).team == team then
			return old_is_protected(pos, name)
		end
	end

	minetest.chat_send_player(name, "You cannot dig on team "..team.."'s land")
	return true
end

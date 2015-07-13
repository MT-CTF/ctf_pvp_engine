-- This mod is used to protect nodes in the capture the flag game
local old_is_protected = minetest.is_protected

function minetest.is_protected(pos, name)
	local team = ctf.get_territory_owner(pos)

	if not team or not ctf.team(team) then
		return old_is_protected(pos, name)
	end

	if ctf.player(name).team == team then
		return old_is_protected(pos, name)
	else
		minetest.chat_send_player(name, "You cannot dig on team "..team.."'s land")
		return true
	end
end

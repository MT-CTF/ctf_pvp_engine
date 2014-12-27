-- This mod is used to protect nodes in the capture the flag game

function stop_dig(name,pos)
	local team = ctf.area.get_area(pos)
	
	if not team then
		return false
	end

	if ctf.players and ctf.player(name) and ctf.player(name).team then
		if ctf.player(name).team == team then
			return false
		end
	end

	return team
end

minetest.register_on_dignode(function(pos, oldnode, digger)
	if digger and digger:get_player_name() then
		local res = stop_dig(digger:get_player_name(),pos)
		if res then
			minetest.chat_send_player(digger:get_player_name(),"You can not dig on team "..res.."'s land")
			minetest.env:set_node(pos,oldnode)
		end
	end
end)

minetest.register_on_placenode(function(pos, newnode, placer, oldnode, itemstack)
	if placer and placer:get_player_name() then
		local res = stop_dig(placer:get_player_name(),pos)
		if res then
			minetest.chat_send_player(placer:get_player_name(),"You can not place on team "..res.."'s land")
			minetest.env:set_node(pos,oldnode)
		end
	end
end)
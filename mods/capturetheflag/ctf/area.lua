ctf.area = {}

function ctf.area.get_territory_owner(pos)
	local largest = nil
	local largest_weight = 0
	for i = 1, #ctf.registered_on_territory_query do
		local team, weight = ctf.registered_on_territory_query[i](pos)
		if team and weight then
			if weight == -1 then
				return team
			end
			if weight > largest_weight then
				largest = team
				largest_weight = weight
			end
		end
	end
	return largest
end

-- updates the spawn position for a team
function ctf.area.get_spawn(team)
	ctf_flag.asset_flags(team)

	if not ctf.team(team) then
		return nil
	end

	if ctf.team(team).spawn and minetest.env:get_node(ctf.team(team).spawn).name == "ctf:flag" then
		local flag = ctf_flag.get(ctf.team(team).spawn)

		if not flag then
			return nil
		end

		local _team = flag.team

		-- Check to see if spawn is already defined
		if team == _team then
			return nil
		end
	end

	-- Get new spawn
	if #ctf.team(team).flags > 0 then
		ctf.team(team).spawn = ctf.team(team).flags[1]
		return ctf.team(team).spawn
	end
end

minetest.register_on_respawnplayer(function(player)
	if player and ctf.player(player:get_player_name()) then
		local team = ctf.player(player:get_player_name()).team
		if ctf.team(team) then
			local spawn = ctf.area.get_spawn(team)
			player:moveto(spawn, false)
			return true
		end
	end

	return false
end)

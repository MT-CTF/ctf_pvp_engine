ctf.area = {}

-- add a flag to a team
function ctf.area.add_flag(team,pos)
	if not team or team == "" then
		return
	end

	if not ctf.team(team).flags then
		ctf.team(team).flags = {}
	end

	pos.team = team
	table.insert(ctf.team(team).flags,pos)
	ctf.save()
end

-- get a flag from a team
function ctf.area.get_flag(pos)
	if not pos then
		return
	end

	local result = nil
	for _, team in pairs(ctf.teams) do
		for i = 1, #team.flags do
			if (
				team.flags[i].x == pos.x and
				team.flags[i].y == pos.y and
				team.flags[i].z == pos.z
			) then
				if result then
					minetest.chat_send_all("[CTF ERROR] Multiple teams have same flag. Please report this to the server operator / admin")
					print("CTF ERROR DATA")
					print("Multiple teams have same flag.")
					print("This is a sign of ctf.txt corruption.")
					print("----------------")
					print(dump(result))
					print(dump(team.flags[i]))
					print("----------------")
				else
					result = team.flags[i]
				end
			end
		end
	end
	return result
end

-- delete a flag from a team
function ctf.area.delete_flag(team, pos)
	if not team or team == "" then
		return
	end

	for i = 1, #ctf.team(team).flags do
		if (
			ctf.team(team).flags[i].x == pos.x and
			ctf.team(team).flags[i].y == pos.y and
			ctf.team(team).flags[i].z == pos.z
		) then
			table.remove(ctf.team(team).flags,i)
			return
		end
	end
end

-- Gets the nearest flag in a 25 metre radius block
function ctf.area.nearest_flag(pos)
	if not pos then
		ctf.error("No position provided to nearest_flag()")
		return nil
	end

	local nodes = minetest.find_nodes_in_area(
		{
			x = pos.x - ctf.setting("flag.protect_distance"),
			y = pos.y - ctf.setting("flag.protect_distance"),
			z = pos.z - ctf.setting("flag.protect_distance")
		},
		{
			x = pos.x + ctf.setting("flag.protect_distance"),
			y = pos.y + ctf.setting("flag.protect_distance"),
			z = pos.z + ctf.setting("flag.protect_distance")
		},
		{"group:is_flag"}
	)

	if nodes then
		local closest = nil
		local _dis = 1000

		for a = 1, #nodes do
			local this_dis = vector.distance(pos, nodes[a])
			if this_dis < _dis then
				closest = nodes[a]
				_dis = this_dis
			end
		end

		return closest
	end

	return nil
end

-- gets the name of the owner of that location
function ctf.area.get_area(pos)
	local closest = ctf.area.nearest_flag(pos)
	if not closest then
		return nil
	end
	local flag = ctf.area.get_flag(closest)

	if flag then
		return flag.team
	end
	return nil
end

-- updates the spawn position for a team
function ctf.area.get_spawn(team)
	ctf.area.asset_flags(team)

	if not ctf.team(team) then
		return nil
	end

	if ctf.team(team).spawn and minetest.env:get_node(ctf.team(team).spawn).name == "ctf:flag" then
		local flag = ctf.area.get_flag(ctf.team(team).spawn)

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

function ctf.area.asset_flags(team)
	--[[
	if not team or not ctf.team(team) then
		return false
	end

	ctf.log("utils", "Checking the flags of "..team)

	local tmp = ctf.team(team).flags
	local get_res = minetest.env:get_node(tmp[i])
	for i=1,#tmp do
		if tmp[i] and (not get_res or not get_res.name == "ctf:flag") then
			ctf.log("utils", "Replacing flag...")
			-- TODO: ctf.area.asset_flags
		end
	end]]--
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

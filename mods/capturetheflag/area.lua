cf.area = {}

-- add a flag to a team
function cf.area.add_flag(team,pos)
	if not team or team == "" then
		return
	end

	if not cf.team(team).flags then
		cf.team(team).flags = {}
	end

	pos.team = team
	table.insert(cf.team(team).flags,pos)
	cf.save()
end

-- get a flag from a team
function cf.area.get_flag(pos)
	if not pos then
		return
	end

	local result = nil
	for _, team in pairs(cf.teams) do
		for i = 1, #team.flags do
			if (
				team.flags[i].x == pos.x and
				team.flags[i].y == pos.y and
				team.flags[i].z == pos.z
			) then
				if result then
					minetest.chat_send_all("[CTF WARNING] Multiple teams have same flag. Please report this to the server operator / admin")
					print("CTF WARNING DATA")
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
function cf.area.delete_flag(team,pos)
	if not team or team == "" then
		return
	end

	print(dump(cf.team(team).flags))
	for i = 1, #cf.team(team).flags do
		if (
			cf.team(team).flags[i].x == pos.x and
			cf.team(team).flags[i].y == pos.y and
			cf.team(team).flags[i].z == pos.z
		) then
			table.remove(cf.team(team).flags,i)
			return
		end
	end
end

-- Gets the nearest flag in a 25 metre radius block
function cf.area.nearest_flag(pos)
	if not pos then
		print ("No position provided to nearest_flag()")
		return nil
	end

	print("cf.setting('flag_protect_distance') is "..dump(cf.setting("flag_protect_distance")))

	local nodes = minetest.env:find_nodes_in_area(
		{x=pos.x-cf.setting("flag_protect_distance"),y=pos.y-cf.setting("flag_protect_distance"),z=pos.z-cf.setting("flag_protect_distance")},
		{x=pos.x+cf.setting("flag_protect_distance"),y=pos.y+cf.setting("flag_protect_distance"),z=pos.z+cf.setting("flag_protect_distance")},
		{"group:is_flag"}
	)

	if nodes then
		local closest = nil
		local _dis = 1000

		for a=1, #nodes do
			if v3.distance(pos, nodes[a]) < _dis then
				closest = nodes[a]
				_dis = v3.distance(pos, nodes[a])
			end
		end

		return closest
	end

	return nil
end

-- gets the name of the owner of that location
function cf.area.get_area(pos)
	local closest = cf.area.nearest_flag(pos)
	if not closest then
		return false
	end
	local flag = cf.area.get_flag(closest)
	
	if flag then
		return flag.team
	end
	return false
end

-- updates the spawn position for a team
function cf.area.get_spawn(team)
	cf.area.asset_flags(team)

	if team and cf.teams and cf.team(team) then
		if cf.team(team).spawn and minetest.env:get_node(cf.team(team).spawn).name == "capturetheflag:flag" then
			local flag = cf.area.get_flag(cf.team(team).spawn)
			
			if not flag then
				return false
			end
			
			local _team = flag.team

			-- Check to see if spawn is already defined
			if team == _team then
				return true
			end
		end

		-- Get new spawn
		if #cf.team(team).flags > 0 then
			cf.team(team).spawn = cf.team(team).flags[1]
			return true
		end
	end
	return false
end

function cf.area.asset_flags(team)
	if not team or not cf.team(team) then
		return false
	end
	
	print("Checking the flags of "..team)

	local tmp = cf.team(team).flags

	for i=1,#tmp do
		if tmp[i] and (not minetest.env:get_node(tmp[i]) or not minetest.env:get_node(tmp[i]).name == "capturetheflag:flag") then
			print("Replacing flag...")
		end
	end
end
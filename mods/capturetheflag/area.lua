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
					minetest.chat_send_all("[CTF WARNING] Multiple teams have same flag. please report this to the server operator / admin")
					print("CTF WARNING DATA")
					print("Multiple teams have same flag. See debug log for details")
					print("----------------")
					print(dump(result))
					print(dump(team.flags[i]))
					print("----------------")
				else
					result = {pos=team.flags[i],team=team.data.name}
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

	print("cf.settings.flag_protect_distance is "..dump(cf.settings.flag_protect_distance))

	local nodes = minetest.env:find_nodes_in_area(
		{x=pos.x-cf.settings.flag_protect_distance,y=pos.y-cf.settings.flag_protect_distance,z=pos.z-cf.settings.flag_protect_distance},
		{x=pos.x+cf.settings.flag_protect_distance,y=pos.y+cf.settings.flag_protect_distance,z=pos.z+cf.settings.flag_protect_distance},
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

	local meta = minetest.env:get_meta(closest)
	if not meta then
		return false
	end

	return meta:get_string("team")
end

-- updates the spawn position for a team
function cf.area.get_spawn(team)
	cf.area.asset_flags(team)

	if team and cf.teams and cf.team(team) then
		if cf.team(team).spawn and minetest.env:get_node(cf.team(team).spawn).name == "capturetheflag:flag" then
			-- Get meta data
			local meta = minetest.env:get_meta(cf.team(team).spawn)
			local _team = nil
			if meta then
				_team = meta:get_string("team")
			end

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
	local new = {}

	for i=1,#tmp do
		if tmp[i] and minetest.env:get_node(tmp[i]) and minetest.env:get_node(tmp[i]).name == "capturetheflag:flag" then
			-- Get meta data
			local meta = minetest.env:get_meta(tmp[i])
			local _team = nil
			if meta then
				_team = meta:get_string("team")
			end

			-- Check to see if spawn is already defined
			if team == _team then
				table.insert(new,tmp[i])
			else
				print(_team.." is not "..team.." at "..dump(tmp[i]))
			end
		end
	end
	
	cf.team(team).flags = new
end
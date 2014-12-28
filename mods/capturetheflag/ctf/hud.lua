function hudkit()
	return {
		players = {},

		add = function(self, player, id, def)
			local name = player:get_player_name()
			local elements = self.players[name]

			if not elements then
				self.players[name] = {}
				elements = self.players[name]
			end

			elements[id] = player:hud_add(def)
			return true
		end,

		exists = function(self, player, id)
			if not player then
				return false
			end

			local name = player:get_player_name()
			local elements = self.players[name]

			if not elements or not elements[id] then
				return false
			end
			return true
		end,

		change = function(self, player, id, stat, value)
			if not player then
				return false
			end

			local name = player:get_player_name()
			local elements = self.players[name]

			if not elements or not elements[id] then
				return false
			end

			player:hud_change(elements[id], stat, value)
			return true
		end,

		remove = function(self, player, id)
			local name = player:get_player_name()
			local elements = self.players[name]

			if not elements or not elements[id] then
				return false
			end

			player:hud_remove(elements[id])
			elements[id] = nil
			return true
		end
	}
end

ctf.hud = hudkit()

function ctf.hud.update(player)
	local player_data = ctf.player(player:get_player_name())

	if not player_data or not player_data.team or not ctf.team(player_data.team) then
		return
	end

	-- Team Identifier
	local color = ctf.flag_colors[ctf.team(player_data.team).data.color]
	if not color then
		color = "0x000000"
	end
	if not ctf.hud:exists(player, "ctf:hud_team") then
		return ctf.hud:add(player, "ctf:hud_team", {
			hud_elem_type = "text",
			position = {x = 1, y = 0},
			scale = {x = 100, y = 100},
			text = player_data.team,
			number = color,
			offset = {x=-100, y = 20}
		})
	else
		ctf.hud:change(player, "ctf:hud_team", "text", player_data.team)
		ctf.hud:change(player, "ctf:hud_team", "number", color)
	end
end

local count = 0
function ctf.hud.updateAll()
	count = 0

	if not ctf.setting_bool("hud") then
		return
	end

	local players = minetest.get_connected_players()

	for i = 1, #players do
		ctf.hud.update(players[i])
	end
end
minetest.register_globalstep(function(delta)
	count = count + delta

	if count > 10 then
		ctf.hud.updateAll()
	end
end)

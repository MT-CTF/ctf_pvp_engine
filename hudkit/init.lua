function hudkit()
	return {
		players = {},

		add = function(self, player, id, def)
			local name     = player:get_player_name()
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

			local name     = player:get_player_name()
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

			local name     = player:get_player_name()
			local elements = self.players[name]

			if not elements or not elements[id] then
				return false
			end

			player:hud_change(elements[id], stat, value)
			return true
		end,

		remove = function(self, player, id)
			local name     = player:get_player_name()
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

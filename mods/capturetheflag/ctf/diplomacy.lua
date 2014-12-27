-- diplo states: war, peace, alliance
cf.diplo = {}

function cf.diplo.get(one,two)
	if not cf.diplo.diplo then
        	return cf.setting("default_diplo_state")
	end

	for i=1,#cf.diplo.diplo do
		local dip = cf.diplo.diplo[i]
		if (dip.one == one and dip.two == two) or (dip.one == two and dip.two == one) then
			return dip.state
		end
	end

	return cf.setting("default_diplo_state")
end

function cf.diplo.set(one,two,state)
	if not cf.diplo.diplo then
		cf.diplo.diplo = {}
	else
		for i=1,#cf.diplo.diplo do
			local dip = cf.diplo.diplo[i]
			if (dip.one == one and dip.two == two) or (dip.one == two and dip.two == one) then
				dip.state = state
				return
			end
		end
	end
	
	table.insert(cf.diplo.diplo,{one=one,two=two,state=state})
	return
end

function cf.diplo.check_requests(one,two)
	local team = cf.team(two)
	
	if not team.log then
		return nil
	end
	
	for i=1,#team.log do
		if team.log[i].team == one and team.log[i].type=="request" and team.log[i].mode=="diplo" then
			return team.log[i].msg
		end
	end
	
	return nil
end

function cf.diplo.cancel_requests(one,two)
	local team = cf.team(two)
	
	if not team.log then
		return
	end
	
	for i=1,#team.log do
		if team.log[i].team == one and team.log[i].type=="request" and team.log[i].mode=="diplo" then
			table.remove(team.log,i)
			return
		end
	end
	
	return
end
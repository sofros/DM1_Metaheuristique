function repair()
	sol = Bool[1, 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 0, 1, 1, 1, 1, 1, 1, 1, 0, 0, 0, 0, 1, 1, 1, 1, 1, 0, 0, 0, 1, 0, 1, 0, 0, 1, 0, 1, 0, 1, 1, 0, 0, 1, 1, 1, 0, 1, 1, 1, 1, 1, 1, 0, 1, 1, 0, 0, 1, 0, 0, 1, 0, 1, 0, 0, 0, 1, 1, 1, 1, 1, 1, 1, 0, 0, 1, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 0, 0, 0, 0, 1, 1, 1, 0, 1, 0, 0, 0, 0, 1, 1, 0, 1, 1, 1, 1, 1, 1, 1, 0, 1, 1, 1, 0, 0, 1, 1, 1, 0, 0, 1, 0, 0, 1, 1, 1, 1, 1, 1, 0, 0, 0, 1, 0, 1, 1, 0, 0, 1, 0, 0, 0, 1, 0, 0, 1, 0, 0, 1, 0, 1, 1, 1, 1, 0, 0, 1, 1, 1, 1, 1, 1, 0, 1, 1, 1, 1, 0, 1, 1, 1, 1, 1, 0, 0, 1, 1, 0, 1, 0, 0, 0, 1, 0, 0, 1, 0, 1, 1, 1, 0, 1, 0, 1, 1, 0, 0, 1]
	cost,matrix = loadSPP("instances/pb_200rnd0900.dat")
	println("avant repair : z = ", transpose(sol) * cost)

	constr_violated = Int64[]
	cst = matrix*sol
	for i = 1:length(cst)
		if cst[i] > 1
			push!(constr_violated, i)
		end
	end
	# println(constr_violated)

	var_1 = Int64[]
	for i = 1:length(sol)
		if sol[i] == 1
			push!(var_1, i)
		end
	end
	# println(var_1)
	var_1_conflit = Int64[]
	for i = 1:length(sol)
		if sol[i] == 1
			for cst in constr_violated
				if matrix[cst,i] == 1
					push!(var_1_conflit, i)
				end
			end
		end
	end
	# println(var_1_conflit)
	while length(constr_violated) != 0
		# println("--------------------")
		inu = inutilite(var_1_conflit, constr_violated, cost, matrix)
		# println("inutility = ", inu)
		e = getBestInutil(var_1_conflit, inu)
		# println("variable a mettre a zero :", e)
		sol[e] = 0

		# ind = findfirst((x -> x == e),var_1_conflit)
		# deleteat!(var_1_conflit,ind)

		var_1_conflit = Int64[]
		for i = 1:length(sol)
			if sol[i] == 1
				for cst in constr_violated
					if matrix[cst,i] == 1
						push!(var_1_conflit, i)
					end
				end
			end
		end

		# println("var_1_conflit = ", var_1_conflit)
		constr_violated = updateCstV(constr_violated, sol, matrix)
		# println("constr_violated", constr_violated)
	end
	println("apres repair : z = ", transpose(sol) * cost)
	return sol
end

function getBestInutil(var_1::Array{Int64,1}, inutility::Array{Float64,1})
	max_x = 0
	max_inu = 0.0
	for j in 1:length(var_1)
		if inutility[j] > max_inu
			max_inu = inutility[j]
			max_x = var_1[j]
		end
	end
	return max_x
end

function inutilite(var_1, constr, cost, matrix)
	inu = zeros(Float64, length(var_1))
	i = 1
	for var in var_1
		sum = 0
		for cst in constr
			sum = sum + matrix[cst,var]
		end
		inu[i] = sum / cost[i]
		i = i + 1
	end
	return inu
end

function updateCstV(constr_violated, sol, matrix)
	# res = copy(constr_violated)
	# for constr in constr_violated
	# 	if transpose(matrix[:,constr])*sol <= 1
	# 		ind = findfirst((x -> x == constr),res)
	# 		deleteat!(res,ind)
	# 	end
	# end
	# return res
	constr_violated = Int64[]
	cst = matrix*sol
	for i = 1:length(cst)
		if cst[i] > 1
			push!(constr_violated, i)
		end
	end
	return constr_violated
end

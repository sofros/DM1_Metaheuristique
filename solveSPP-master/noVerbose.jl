#include("main.jl")
#Generation d'une population
include("DM2_exp.jl")
#parametre génération de population
alpha1 = 0.2
alpha2 = 0.6
alpha3 = 0.8
alphaS = [alpha1, alpha2, alpha3]
population = []
#paramétre de selection et de filliation
nbrParticipants = 16
nbrSelectionné = 4
chanceMut = 0.5
taillePop = 120
cuts = []
nbrEnfants = 10
nbrCuts = 7
nbrGen = 100
#Array{(Array{Bool,1}),Int64)}


function genPop(cost, matrix, n, m, alphaS)
    for i in 1:40
        (SOL, z, desactive_condition) = GRASP(cost, matrix, n, m, alphaS[1])
        push!(population, (SOL, z))
        (SOL, z, desactive_condition) = GRASP(cost, matrix, n, m, alphaS[2])
        push!(population, (SOL, z))
        (SOL, z) = UpgradeGRASP(cost, matrix, n, m, alphaS[3])
        ##println(typeof(z))
        push!(population, (SOL, z))
    end
    ##println(population)
#    for x in population
#        afficheSol(x)
#    end
    #println(typeof(population))
    sort!(population, by = x -> x[2])
    #println("\n\n\n")
    ##println(population)
#    for x in population
#        afficheSol(x)
#    end
    return(population)
end

function evaluateLarge(population)
    sort!(population, by = x -> x[2])
    bas = deepcopy(population[1:Int64(floor(end/2))])
    moyen = deepcopy(population[end-79:end-40])
    elite = deepcopy(population[end-39:end])
    return(bas,moyen,elite)
end

function evaluate(population)
    sort!(population, by = x -> x[2])
    bas = deepcopy(population[end-119:end-80])
    moyen = deepcopy(population[end-79:end-40])
    elite = deepcopy(population[end-39:end])
    return(bas,moyen,elite)
end

function roulette(population, tailleSelec)#la taille du tournoi sera le nombre de participants au départ, elle doit être un multiple de 2
    selection = []
    probaSelec = Array{Float64}(undef, length(population))
    for i in 1:length(population)
        probaSelec[i] = i/length(population)
    end
    #println("probaSelec: ", probaSelec)
    noInf = 4
    while length(selection) < tailleSelec
        j = 1
        i = 1
        choisie = rand(Float64,tailleSelec)
        sort!(choisie)
        #println("choisie: ", choisie)
        while i <= length(population) && j <= tailleSelec
            if choisie[j] <= probaSelec[i] && j<=tailleSelec
                j += 1
                push!(selection, population[i])
                #println(i, " sélectionné")
            end
            i += 1
            #println("i= ", i, "  j = ", j)
        end
    end
    selection = selection[1:tailleSelec]

    #println("taille de la selection:  ", length(selection))
    #println(selection)

    return(selection)
end

function TournoiMeilleur(participant, nbrSelectionne) #le nombre de participants et de selection doivent être des puissances de 2 avec nbrSelection < nbrParticipant
    sort!(participant, by = x -> x[2])
    pool1 = participant[1:Int64((length(participant)/2))]
    pool2 = participant[(Int64(length(participant)/2)+1):end]
    qualifié = participant

    while  length(qualifié) > nbrSelectionne
        qualifié = []
        for i in 1:length(pool1)
            randomNumber = rand(Float64)
            if randomNumber >= 0.75
                push!(qualifié, pool1[i])
            else
                push!(qualifié, pool2[i])
            end
        end
        sort!(qualifié, by = x -> x[2])
        pool1 = qualifié[1:Int64((length(qualifié)/2))]
        pool2 = qualifié[Int64((length(qualifié)/2)+1):end]
    end
    #println("Fin tournoi meilleur avec ", length(qualifié), " qualifié!")
    #println("qualifié: ", qualifié)
    return(qualifié)
end

function TournoiMoinsBon(participant, nbrSelectionne) #le nombre de participants et de selection doivent être des puissances de 2 avec nbrSelection < nbrParticipant
    sort!(participant, by = x -> x[2])
    pool1 = participant[1:Int64((length(participant)/2))]
    pool2 = participant[(Int64(length(participant)/2)+1):end]
    qualifié = participant

    while  length(qualifié) > nbrSelectionne
        qualifié = []
        for i in 1:length(pool1)
            randomNumber = rand(Float64)
            if randomNumber <= 0.75
                push!(qualifié, pool1[i])
            else
                push!(qualifié, pool2[i])
            end
        end
        sort!(qualifié, by = x -> x[2])
        pool1 = qualifié[1:Int64((length(qualifié)/2))]
        pool2 = qualifié[Int64((length(qualifié)/2)+1):end]
    end
    #println("Fin tournoi moins bon avec ", length(qualifié), " qualifié!")
    #println("qualifié: ", qualifié)
    return(qualifié)
end

function crossOver(A, B, cuts)
    #Init variables
    fils = Vector{Array{Int64,1}}(undef,2^(length(cuts)+1))
    k=2
    m = length(fils)/2
    #Init tableau des enfants
    #println("A: ", A)
    #println("B: ", B)
    for i in 1:length(fils)
        fils[i] = []
        if i > m
            fils[i] = vcat(fils[i], B[1:(cuts[1])])
        else
            fils[i] = vcat(fils[i], A[1:(cuts[1])])
        end
    end
    #Debut du crossover
    for i in 1:length(cuts)-1 #On ajoute les coupes
        k = k*2
        for j in 1:k #partie du tableau
            for l in 1:Int64(length(fils)/k) #nbr d'éléments changé
                m = l+(j-1)*Int64(length(fils)/k)
                if j%2 == 1
                    fils[m] = vcat(fils[m], A[cuts[i]+1:(cuts[i+1])])
                else
                    fils[m] = vcat(fils[m], B[cuts[i]+1:(cuts[i+1])])
                end #fin if
            end #fin acces case à case
       end #On sectionne le tableau en 2^k parties
   end #end for de boucle
   #On finie de remplir le tableau, les gènes de A sont présent 1 case sur 2
   for j in 1:length(fils)
       if j % 2 == 1
           fils[j] = vcat(fils[j], A[(cuts[end]+1):end])
       else
           fils[j] = vcat(fils[j], B[(cuts[end]+1):end])
       end
   end
   return(fils[2:(end-1)])
end#Fin de crossOver

function mortalitéInfantile(enfants,nbrSurvivants)
    for i in 1:(length(enfants)-nbrSurvivants)
        mort = rand(1:length(enfants))
        #println("L'enfant: ", mort, " est mort.")
        deleteat!(enfants, mort)
    end
    return(enfants)
end

#=

function smartRepair(matrix , cost, x)
    conflit = transpose(matrix*x)
    ##println("conflits init: ", conflit)
    numConflits = Int64[]
    for i in 1:length(conflit) #identification des conflits
        if conflit[i] > 1
            push!(numConflits, i)
        end
    end
    #println("taille de numConflits: ", length(numConflits), "   numConflits: ", numConflits)
    cpt = 0
    while length(numConflits) > 0  && cpt < 30
        numConflits = Int64[]
        sousMatConflits = []
        for i in 1:length(conflit) #identification des conflits
            if conflit[i] > 1
                push!(numConflits, i)
            end
        end
        #println("num des conflits: ", numConflits)
        for i in numConflits
            push!(sousMatConflits, matrix[i,1:end])
        end
        #println("Sous matrice de conflits: ", sousMatConflits)
        #Calcul de l'inutilitée
        inutile = inutilitée(x, cost, sousMatConflits)
        #Drop de la variable conflictuelle la moins Utilite
        dropID = maxID(inutile)
        #println("variable droppé: ", dropID)
        x[dropID] = false
        conflit = transpose(matrix*x)
        ##println("conflit : ", conflit)
        cpt += 1
    end
    z = transpose(x) * cost
    return(x , z)
    #=
    while (map(x -> x <= 1, conflits) != ones(Bool,length(x)))
        inutilité = inutile(x, cost, matrix)
        drop = maxID(inutilité)
        x[drop] = false
        conflits = traspose(x*matrix)
    end
    z = transpose(x)*cost
    =#
    return(x,z)
end

=#


function smartRepair(matrix , cost, x)
    conflit = transpose(matrix*x)
    ##println("conflits init: ", conflit)
    numConflits = Int64[]
    for i in 1:length(conflit) #identification des conflits
        if conflit[i] > 1
            push!(numConflits, i)
        end
    end
    #println("taille de numConflits: ", length(numConflits), "   numConflits: ", numConflits)
    #cpt = 0
    while length(numConflits) > 0 # && cpt < 400
		#println("---------------------------------------")
        numConflits = Int64[]
        sousMatConflits = []
        for i in 1:length(conflit) #identification des conflits
            if conflit[i] > 1
                push!(numConflits, i)
            end
        end
        #println("num des conflits: ", numConflits)
        for i in numConflits
            push!(sousMatConflits, matrix[i,1:end])
        end

		#print("sol = ")
		for i in 1:length(x)
			if x[i] == 1
				#print(i," ")
			end
		end
		#println()
		#println("Sous matrice de conflits: ")
		for i in 1:length(sousMatConflits)
			#print("constr ", i, " : ")
			for j in 1:length(sousMatConflits[i])
				if sousMatConflits[i][j] == 1
					#print(j, " ")
				end
			end
			#println()
		end

        # #println("Sous matrice de conflits: ", sousMatConflits)
        #Calcul de l'inutilitée
        inutile = inutilitée(x, cost, sousMatConflits)
		#println(inutile)
        #Drop de la variable conflictuelle la moins Utilite
        dropID = maxID(inutile)
        #println("variable droppé: ", dropID)
        x[dropID] = false
        conflit = transpose(matrix*x)
        # #println("conflit : ", conflit)
        #cpt += 1
    end
    m = length(x)
    z = calculz(x,cost,m)
    #println("z dans le repair:", z)
    return(x , z)
    #=
    while (map(x -> x <= 1, conflits) != ones(Bool,length(x)))
        inutilité = inutile(x, cost, matrix)
        drop = maxID(inutilité)
        x[drop] = false
        conflits = traspose(x*matrix)
    end
    z = transpose(x)*cost
    =#
end

#=
function inutilitée(x, cost, sousMatConflits)
    inutilité = Array{Float64}(undef, length(x))
    for i in 1:length(x) #Pour chaque variable
        cpt = 0
        for j in 1: length(sousMatConflits) #On regarde chaque contraite
            if sousMatConflits[j][i] == true
                cpt += 1
            end
        end
        inutilité[i] = cpt/cost[i]
    end
    return(inutilité)
end
=#
function inutilitée(x, cost, sousMatConflits)
    inutilité = Array{Float64}(undef, length(x))
    for i in 1:length(x) #Pour chaque variable
        cpt = 0
        if x[i] == 1
            for j in 1: length(sousMatConflits) #On regarde chaque contraite
                if sousMatConflits[j][i] == 1
                    cpt += 1
                end
            end
        end
        inutilité[i] = cpt/cost[i]
    end
    return(inutilité)
end

function maxID(liste)
    ID = 1
    for i in 2:length(liste)
        if liste[i] > liste[ID]
            ID = i
        end
    end
    return(ID)
end

function mutation(x, matrix, cost, chanceMut)
    randomNumber = rand(Float64)
    #println("Mutation? RGN: ", randomNumber, "   chanceMut: ", chanceMut)
    m, n = size(matrix)
    if randomNumber <= chanceMut
        randomNumber = rand(1:4)
        #println("mutation choisie: ", randomNumber)
        if randomNumber == 1 #simple 1-1exchange
            crts = matrix * x
            #println("simple 1-1exchange")
            (x, z) = exchange1_1(x, n, m, cost, crts, matrix)
        elseif randomNumber == 2 #simple  1-2 exchange
            crts = matrix * x
            #println("simple  1-2 exchange")
            (x, z) = exchange1_2(x, n, m, cost, crts, matrix)
        elseif randomNumber == 3 #descent 1-2 & 1-1 exchange
            #println("#descent 1-2 & 1-1 exchange")
            crts = matrix * x
            z1 = transpose(x) * cost
            z2 = 0
            while z2 > z1
                #println("avant alélioration: ", z1)
                (x,z2) = exchange1_2(x, n, m, cost, crts, matrix)
                (x,z2) = exchange1_1(x, n, m, cost, crts, matrix)
                z1 = z2
                #println("aprés amélioration: ", z1)
            end
            z = transpose(x) * cost
        else
            #println("addOrElseDrop")
            x = addOrElseDrop(x, matrix)
            x = smartRepair(matrix , cost, x)
            z = transpose(x[1]) * cost
        end
    else
        #println("Pas de mutation!")
        z = transpose(x) * cost
    end
    if length(x) == 2
        return(x)
    else
        return( x , z)
    end

end

function addOrElseDrop(x, matrix)
    listeFalse = []
    for i in 1:length(x)
        if x[i] == false
            push!(listeFalse, i)
        end
    end
    randomNumber = rand(listeFalse)
    #debut du Add
    #println("add de la variable: ", randomNumber)
    x[randomNumber] = true
    conflit = transpose(matrix*x)
    for i in 1:length(conflit) #verification des conflits
        if conflit[i] > 1 #partie "elseDrop"
            #println("conflit detecté")
            x[randomNumber] = false #retour à la soltion de départ
            #drop
            listeTrue = []
            for j in 1:length(x)
                if x[j] == 1
                    push!(listeTrue, j)
                end  #fin if
            end # fin contruction listeTrue
            drop = rand(listeTrue)
            #println("drop de la variable: ", drop)
            x[drop] = false
            conflit = transpose(matrix*x)
        end #fin du else drop
    end # fin de verification de conflits
    return(x)
end

function genEnfants(parents1, parents2, nbrCuts, nbrEnfants, chanceMut, matrix, cost)
    #println("Debut genEnfants")
    enfants = []
    enfantFinal = []

    for i in 1:length(parents1)
        #println("crossOver n°", i)
        cuts = genCuts(length(parents1[1][1]), nbrCuts)
        #println("cuts = ",cuts)
        enfants =  union(enfants,crossOver(parents1[i][1], parents2[i][1], cuts))
        #println("fin crossOver n°", i)
    end
    #println("taille enfant avant mortalité: ", length(enfants))
    enfants = mortalitéInfantile(enfants, nbrEnfants)
    #println("taille enfant après mortalité: ", length(enfants))
    #println("enfants: ", enfants)


    cpt = 0
    for x in enfants
        cpt += 1
        #println("\n reparation enfant n°", cpt)
        #println("x =", x)
        x = smartRepair(matrix , cost, x)
        #println("admissibilité post repair: ", is_admissible(x, cost, matrix))
        if is_admissible(x, cost, matrix)[3] == false
            #println(transpose(matrix*x[1]))
            x = smartRepair(matrix , cost, x[1])
            #println(transpose(matrix*x[1]))
        end
        #println("enfant ", cpt, " réparé!")
        #println("enfant après répa:", x)
        x = mutation(x[1], matrix, cost, chanceMut)
        #println("admissibilité post mutation: ", is_admissible(x, cost, matrix))
        if is_admissible(x, cost, matrix)[3] == false
            #println("\n \n\n",transpose(matrix*x[1]))
            #println("z avant le repair: ", x[2])
            x = smartRepair(matrix , cost, x[1])
            #println(transpose(matrix*x[1]))
        end
        #println("z pas dans le repair: ", x[2])
        #println("enfant après :", x)
        #println("admissibilité juste au cas où...: ", is_admissible(x, cost, matrix))
        push!(enfantFinal, x)
    end

    return(enfantFinal)
end

function genCuts(taille, nbrCuts)
    cuts = []
    #println("cuts ini: ", cuts, "   taille: ", taille, "   NbrCuts: ", nbrCuts)
    cpt = 0
    while length(cuts) != nbrCuts && cpt < 100
        cpt += 1
        randomNumber = rand(2:taille-1)
        push!(cuts, randomNumber)
        #println("cut n°", cpt, " = ", cuts)
    end
    sort!(cuts)
    return(cuts)
end

function afficheSol(x)
    print("Valeur solution: ", x[2], "   ")

    print("Valeurs actives: ")
    for i in 1:length(x[1])
        if x[1][i] == 1
            print( i , " ")
        end
    end
end

function afficheValSol(x)
    println(x[2])
end

# Verifie si une solution @sol est admissible
#function is_admissible(sol::Tuple{Array{Bool,1},Int64}, cost::Array{Int64,1}, matrix::Array{Int64,2})
function is_admissible(sol, cost::Array{Int64,1}, matrix::Array{Int64,2})
    valAdmissible = true
    solAdmissible = true
    admissible = true

    cst = matrix*sol[1]
    for i = 1:length(cst)
        if cst[i] > 1
            solAdmissible = false
        end
    end

    if (transpose(sol[1])*cost)[1] != sol[2]
        valAdmissible = false
    end
    admissible = solAdmissible && valAdmissible
    return (solAdmissible, valAdmissible, admissible)
end

function smartRepairVerbose(matrix , cost, x)
    conflit = transpose(matrix*x)
    #println("conflits init: ", conflit)
    numConflits = Int64[]
    for i in 1:length(conflit) #identification des conflits
        if conflit[i] > 1
            push!(numConflits, i)
        end
    end
    println("taille de numConflits: ", length(numConflits), "   numConflits: ", numConflits)
    cpt = 0
    while length(numConflits) > 0  && cpt < 10
		println("---------------------------------------")
        numConflits = Int64[]
        sousMatConflits = []
        for i in 1:length(conflit) #identification des conflits
            if conflit[i] > 1
                push!(numConflits, i)
            end
        end
        println("num des conflits: ", numConflits)
        for i in numConflits
            push!(sousMatConflits, matrix[i,1:end])
        end

		print("sol = ")
		for i in 1:length(x)
			if x[i] == 1
				print(i," ")
			end
		end
		println()
		println("Sous matrice de conflits: ")
		for i in 1:length(sousMatConflits)
			print("constr ", i, " : ")
			for j in 1:length(sousMatConflits[i])
				if sousMatConflits[i][j] == 1
					print(j, " ")
				end
			end
			println()
		end

        # println("Sous matrice de conflits: ", sousMatConflits)
        #Calcul de l'inutilitée
        inutile = inutilitée(x, cost, sousMatConflits)
		println(inutile)
        #Drop de la variable conflictuelle la moins Utilite
        dropID = maxID(inutile)
        println("variable droppé: ", dropID)
        x[dropID] = false
        conflit = transpose(matrix*x)
        # println("conflit : ", conflit)
        cpt += 1

    end
    z = transpose(x) * cost
    return(x , z)
    #=
    while (map(x -> x <= 1, conflits) != ones(Bool,length(x)))
        inutilité = inutile(x, cost, matrix)
        drop = maxID(inutilité)
        x[drop] = false
        conflits = traspose(x*matrix)
    end
    z = transpose(x)*cost
    =#
end

#======================================================#

function expPop(fnames)
    for f in fnames
        println("====================================================================")
        println(f)
        cost, matrix, n, m = loadSPP(f)
        population = genPop(cost, matrix, n, m, alphaS)
        (bas, moyen, elite) = evaluate(population)
        println("\nelite:\n")
        for x in elite
            afficheValSol(x)
        end
        for i in 1:nbrGen
            participant = roulette(elite, nbrParticipants)
            selecElite = TournoiMeilleur(participant, nbrSelectionné)
            #println("\n selection elite: ",selecElite)
            participant = roulette(bas, nbrParticipants)
            selecBas = TournoiMoinsBon(participant, nbrSelectionné)
            #println("\n selection bas: ",selecBas)
            enfants = genEnfants(selecBas, selecElite, nbrCuts, nbrEnfants, chanceMut, matrix, cost)
            population = vcat(population, enfants)
            if elite[1][2]/elite[end][2] < 0.99
                (bas, moyen, elite) = evaluate(vcat(population, enfants))
            else
                (bas, moyen, elite) = evaluateLarge(vcat(population, enfants))
            end
            repairElite = []
            for x in elite
                push!(repairElite, x)
            end
            println("~~~~~~~~~~~~~~~~~~~~~~~~~~")
            println("Génération n°: ", i)
            println("Elite: ")
            for x in repairElite
                afficheValSol(x)
            end
            #print(repairElite)
        end
        afficheSol(elite[end])
    end
    cd("../")
end

expPop(fnames)

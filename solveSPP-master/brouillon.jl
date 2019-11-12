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
chanceMut = 0.75
taillePop = 120
cuts = []
nbrEnfants = 60
nbrCuts = 4
nbrGen = 5
#Array{(Array{Bool,1}),Int64)}


function genPop(cost, matrix, n, m, alphaS)
    for i in 1:40
        (SOL, z, desactive_condition) = GRASP(cost, matrix, n, m, alphaS[1])
        push!(population, (SOL, z))
        (SOL, z, desactive_condition) = GRASP(cost, matrix, n, m, alphaS[2])
        push!(population, (SOL, z))
        (SOL, z) = UpgradeGRASP(cost, matrix, n, m, alphaS[3])
        #println(typeof(z))
        push!(population, (SOL, z))
    end
    #println(population)
    for x in population
        afficheSol(x)
    end
    println(typeof(population))
    sort!(population, by = x -> x[2])
    println("\n\n\n")
    #println(population)
    for x in population
        afficheSol(x)
    end
    return(population)
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
    println("probaSelec: ", probaSelec)
    noInf = 4
    while length(selection) < tailleSelec
        j = 1
        i = 1
        choisie = rand(Float64,tailleSelec)
        sort!(choisie)
        println("choisie: ", choisie)
        while i <= length(population) && j <= tailleSelec
            if choisie[j] <= probaSelec[i] && j<=tailleSelec
                j += 1
                push!(selection, population[i])
                println(i, " sélectionné")
            end
            i += 1
            println("i= ", i, "  j = ", j)
        end
    end
    selection = selection[1:tailleSelec]

    println("taille de la selection:  ", length(selection))
    println(selection)

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
    println("Fin tournoi meilleur avec ", length(qualifié), " qualifié!")
    println("qualifié: ", qualifié)
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
    println("Fin tournoi moins bon avec ", length(qualifié), " qualifié!")
    println("qualifié: ", qualifié)
    return(qualifié)
end

function crossOver(A, B, cuts)
    #Init variables
    fils = Vector{Array{Int64,1}}(undef,2^(length(cuts)+1))
    k=2
    m = length(fils)/2
    #Init tableau des enfants
    println("A: ", A)
    println("B: ", B)
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
        println("L'enfant: ", mort, " est mort.")
        deleteat!(enfants, mort)
    end
    return(enfants)
end

#=

function smartRepair(matrix , cost, x)
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
    while length(numConflits) > 0  && cpt < 30
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
        println("Sous matrice de conflits: ", sousMatConflits)
        #Calcul de l'inutilitée
        inutile = inutilitée(x, cost, sousMatConflits)
        #Drop de la variable conflictuelle la moins Utilite
        dropID = maxID(inutile)
        println("variable droppé: ", dropID)
        x[dropID] = false
        conflit = transpose(matrix*x)
        #println("conflit : ", conflit)
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
    println("Mutation? RGN: ", randomNumber, "   chanceMut: ", chanceMut)
    m, n = size(matrix)
    if randomNumber <= chanceMut
        randomNumber = rand(1:4)
        println("mutation choisie: ", randomNumber)
        if randomNumber == 1 #simple 1-1exchange
            crts = matrix * x
            println("simple 1-1exchange")
            (x, z) = exchange1_1(x, n, m, cost, crts, matrix)
        elseif randomNumber == 2 #simple  1-2 exchange
            crts = matrix * x
            println("simple  1-2 exchange")
            (x, z) = exchange1_2(x, n, m, cost, crts, matrix)
        elseif randomNumber == 3 #descent 1-2 & 1-1 exchange
            println("#descent 1-2 & 1-1 exchange")
            crts = matrix * x
            z1 = transpose(x) * cost
            z2 = 0
            while z2 > z1
                println("avant alélioration: ", z1)
                (x,z2) = exchange1_2(x, n, m, cost, crts, matrix)
                (x,z2) = exchange1_1(x, n, m, cost, crts, matrix)
                z1 = z2
                println("aprés amélioration: ", z1)
            end
            z = transpose(x) * cost
        else
            println("addOrElseDrop")
            x = addOrElseDrop(x, matrix)
            x = smartRepair(matrix , cost, x)
            z = transpose(x[1]) * cost
        end
    else
        println("Pas de mutation!")
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
    println("add de la variable: ", randomNumber)
    x[randomNumber] = true
    conflit = transpose(matrix*x)
    for i in 1:length(conflit) #verification des conflits
        if conflit[i] > 1 #partie "elseDrop"
            println("conflit detecté")
            x[randomNumber] = false #retour à la soltion de départ
            #drop
            listeTrue = []
            for j in 1:length(x)
                if x[j] == 1
                    push!(listeTrue, j)
                end  #fin if
            end # fin contruction listeTrue
            drop = rand(listeTrue)
            println("drop de la variable: ", drop)
            x[drop] = false
            conflit = transpose(matrix*x)
        end #fin du else drop
    end # fin de verification de conflits
    return(x)
end

function genEnfants(parents1, parents2, nbrCuts, nbrEnfants, chanceMut, matrix, cost)
    println("Debut genEnfants")
    enfants = []
    enfantFinal = []

    for i in 1:length(parents1)
        println("crossOver n°", i)
        cuts = genCuts(length(parents1[1][1]), nbrCuts)
        println("cuts = ",cuts)
        enfants =  union(enfants,crossOver(parents1[i][1], parents2[i][1], cuts))
        println("fin crossOver n°", i)
    end
    println("taille enfant avant mortalité: ", length(enfants))
    enfants = mortalitéInfantile(enfants, nbrEnfants)
    println("taille enfant après mortalité: ", length(enfants))
    println("enfants: ", enfants)


    cpt = 0
    for x in enfants
        cpt += 1
        println("\n reparation enfant n°", cpt)
        println("x =", x)
        x = smartRepair(matrix , cost, x)
        println("enfant ", cpt, " réparé!")
        println("enfant après répa:", x)
        x = mutation(x[1], matrix, cost, chanceMut)
        println("enfant après :", x)
        push!(enfantFinal, x)
    end

    return(enfantFinal)
end

function genCuts(taille, nbrCuts)
    cuts = []
    println("cuts ini: ", cuts, "   taille: ", taille, "   NbrCuts: ", nbrCuts)
    cpt = 0
    while length(cuts) != nbrCuts && cpt < 100
        cpt += 1
        randomNumber = rand(2:taille-1)
        push!(cuts, randomNumber)
        println("cut n°", cpt, " = ", cuts)
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
    println("")
end

#======================================================#

function expPop(fnames)
    for f in fnames
        println("====================================================================")
        println(f)
        cost, matrix, n, m = loadSPP(f)
        population = genPop(cost, matrix, n, m, alphaS)
        (bas, moyen, elite) = evaluate(population)
        println("bas:\n")
        for x in bas
            afficheSol(x)
        end
        println("\nmoyen:\n")
        for x in moyen
            afficheSol(x)
        end
        println("\nelite:\n")
        for x in elite
            afficheSol(x)
        end



        for i in 1:nbrGen
            participant = roulette(elite, nbrParticipants)
            selecElite = TournoiMeilleur(participant, nbrSelectionné)
            println("\n selection elite: ",selecElite)
            participant = roulette(bas, nbrParticipants)
            selecBas = TournoiMoinsBon(participant, nbrSelectionné)
            println("\n selection bas: ",selecBas)
            enfants = genEnfants(selecBas, selecElite, nbrCuts, nbrEnfants, chanceMut, matrix, cost)
            population = vcat(population, enfants)
            (bas, moyen, elite) = evaluate(vcat(population, enfants))
            for x in elite
                afficheSol(x)
            end
        end

#=
        participant = roulette(elite, nbrParticipants)
        selecElite = TournoiMeilleur(participant, nbrSelectionné)
        participant = roulette(bas, nbrParticipants)
        selecBas = TournoiMoinsBon(participant, nbrSelectionné)
        enfants = genEnfants(selecBas, selecElite, nbrCuts, nbrEnfants, chanceMut, matrix, cost)
        #println("affichage des enfants brut:")
        #println(enfants)
        for x in enfants
            afficheSol(x)
        end

        println("Taille pop avant fusion: ", length(population))
        println("Taille enfants: ", length(enfants))
        population = vcat(population, enfants)
        println("Taille pop après fusion: ", length(population))
        (bas, moyen, elite) = evaluate(vcat(population, enfants))
        println("bas, ",length(bas),"\n")
        for x in bas
            afficheSol(x)
        end
        println("\nmoyen:",length(moyen),"\n")
        for x in moyen
            afficheSol(x)
        end
        println("\nelite:",length(elite), "\n")
        for x in elite
            afficheSol(x)
        end
=#
        #survivant = mortalitéInfantile(selecBas, 1)
        #println("Survivant: ", survivant)
        #a = Bool[0, 1, 0, 0, 0, 1, 0, 1, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
        #a = survivant[1][1]
        #println("a: ", a)
        #println("matrix: ", matrix)
        #b = smartRepair(matrix , cost, a)
        #b = mutation(a, matrix, cost, chanceMut)
        #println("b: ", b)
    end
    cd("../")
end

expPop(fnames)



#===
#Fuction crossOver
x1 = [1, 1, 1, 1, 1, 1, 1, 1]
x2 = [2, 2, 2, 2, 2, 2, 2, 2]
cuts = [2, 4, 6]

function crossOver(A, B, cuts)

   fils = Vector{Array{Int64,1}}(undef,2^(length(cuts)+1))
   println("ini:\n" ,fils)

   k=2

   m = length(fils)/2
   for i in 1:length(fils)
       fils[i] = []
       if i > m
           fils[i] = vcat(fils[i], B[1:(cuts[1])])
       else
           fils[i] = vcat(fils[i], A[1:(cuts[1])])
       end
   end
   println("x=0 \n",fils)

   for i in 1:length(cuts)-1
       println("i= ",i)
       #println(fils)
       k = k*2




              for j in 1:k #partie du tableau
                   for l in 1:Int64(length(fils)/k) #nbr d'éléments changé
                       m = l+(j-1)*Int64(length(fils)/k)
                       if j%2 == 1
                           fils[m] = vcat(fils[m], A[cuts[i]+1:(cuts[i+1])])
                       else
                           fils[m] = vcat(fils[m], B[cuts[i]+1:(cuts[i+1])])
                       end
                   end
              end


       println(fils)
   end

   println("fin")
   for j in 1:length(fils)
       if j % 2 == 1
           fils[j] = vcat(fils[j], A[(cuts[end]+1):end])
       else
           fils[j] = vcat(fils[j], B[(cuts[end]+1):end])
       end
   end
   println(fils)
end

crossOver(x1, x2, cuts)
===#

#===

DM2_2 après edit


include("DM1_1.jl")
include("DM2_1.jl")
include("DM1_2.jl")

#======================================================================#
function ReactiveGRASP(
    matrix, #matrice de taille m*n representant les condion de notre SPP
    cost, #liste des couts de taille n de notre SPP
    n, #nombre de variable de notre SPP
    m, #nombre de condtion de notre SPP
    ite, #nombre de tirage au sort de alpha avant recalcul des probabilités
    coupe, #nombre de coupe du segment [0,1], si on à pas de liste alpha personalisé
    alphaset, #permet de passer une liste de alpha personnelle
    temps #ressource en seconde alloué a notre reactive-GRASP
    )

    #initialisation
    (p,nb_iteration,z_cumul,zBest,zWorst) = intialiser(matrix,cost, n, m, ite, coupe, alphaset)
    liste_alpha = deepcopy(p)
    evol_p = Float64[]

    liste_zmax = Int64[]
    liste_zavg = Float64[]
    liste_zmin = Int64[]

    t=time()
    z_global = zeros(Int64, length(p))
    ite_global = zeros(Int64, length(p))
    nb_boucle = 0

    while (time()-t <= temps)
        append!(evol_p,p) #MaJ de notre historique de probabilité
        cpt=1
        nb_boucle += 1
        #On s'assure que chaque alpha s'exprime au moins une fois.
        for i in 1:length(p)
            (SOL,z, crts) = GRASP(cost, matrix, n, m, liste_alpha[i])
            (SOL, z) = exchange1_1(SOL,n,m,cost,crts,matrix)
            z_cumul[i] += z
            if z < zWorst
                zWorst = z
            elseif z > zBest
                zBest = z
            end
        end #fin for
        while (cpt <= ite)
            #Selection du alpha
            prob = rand(Float64)
            alpha_choisit = choix_alpha(p,prob)
            #On lance GRASP avec cet alpha
            (SOL, z, crts) = GRASP(cost, matrix, n, m, liste_alpha[alpha_choisit])
            #Amelioration
            (SOL, z) = exchange1_1(SOL,n,m,cost,crts,matrix)
            #Réinitialisation
            nb_iteration[alpha_choisit] += 1
            z_cumul[alpha_choisit] += z
            #Mise à jours
            if z > zBest
                zBest = z
            end #fin if
            if z < zWorst
                zWorst = z
            end #fin if
            #Incrément
            cpt = cpt+1
        end #Fin while
        #On recalcul les probabilitées
        recalcul_p!(p,z_cumul,zBest,zWorst,nb_iteration,evol_p)
        #On sovegarde le nombre d'itération et les valeurs de z
        for i in 1:length(p)
            z_global[i] = z_global[i] + z_cumul[i]
            ite_global[i] = ite_global[i] + nb_iteration[i]
        end

        #Calcul de zAvg
        moyenne_global=zeros(Float64,length(p))
        for i in 1:length(p)
            moyenne_global[i] = z_global[i]/ite_global[i]
        end
        zAvg = sum(moyenne_global)/length(p)

        #Push de zMin/Avg/Max dans leurs liste (pour les plots)
        push!(liste_zmax,zBest)
        push!(liste_zavg,zAvg)
        push!(liste_zmin,zWorst)

        nb_iteration = ones(Int64, length(p))
        z_cumul = zeros(Int64, length(p))

    end #fin while
    #Calcul de zAvg
    moyenne_global=zeros(Float64,length(p))
    for i in 1:length(p)
        moyenne_global[i] = z_global[i]/ite_global[i]
    end
    zAvg = sum(moyenne_global)/length(p)

    println("zBest: ", zBest,"   zAvg:  ", zAvg, "    zWorst: ", zWorst , " nombre de recalcul de p: ", nb_boucle)
#    println("liste_zavg: ", liste_zavg, "\n\n liste_zmax:  ", liste_zmax, "\n\n liste_zmin: ", liste_zmin) #A decomenter si l'on souhaite afficehr les évolutions des solutions
#    println(evol_p) #A decommenter si l'on souhaite afficher l'évolution des probabilités
    return(evol_p)
end #fin reactive-GRASP

#=======================================#
function intialiser(matrix, cost, n, m, ite, coupe, alphaset) #initialisation des variables
    p = Float64[]
    if alphaset == 0 #On verifie si on posséde ou non un set
        if coupe >= 1 #On verifie que les coupes sont admissibles
            for i in 1:coupe
                push!(p,i/coupe)
            end #fin for
        end #fin if
    else #on initialise le alphaset
        p = alphaset
    end #fin if

    nb_iteration = ones(Int64, length(p)) #On s'assurera plus tard que tous les alpha s'esprime au moins une fois
    z_cumul = zeros(Int64, length(p)) #Sera une liste de stockage pour le recalcul des probabilités

    (SOL,z) =Glouton(cost, matrix, n, m) #Initialisation d'une solution de base
    zBest = z
    zWorst = z

    return(p,nb_iteration,z_cumul,zBest,zWorst)
end #fin initialiser

#=======================================#
function recalcul_p!(p,z_cumul,zBest,zWorst,nb_iteration,evol_p)
    #initialisation
    q=zeros(Float64,length(p))
    somme_q=0

    for i in 1:length(p)
        moyenne = (z_cumul[i]/nb_iteration[i])
        q[i] = (moyenne-zWorst)/(zBest-zWorst)
        somme_q += q[i]
    end
    for i in 1:length(q)
        p[i] = q[i]/somme_q
    end

    for i in 2:length(p)-1 #On additionne les proabilités entre elles
        p[i] += p[i-1]
    end
    p[length(p)] = 1 #On s'assure qu'il n'y ai pas d'erreur d'arrondie pour 1
end #fin recalcul_p!

#===========================================#
function choix_alpha(p,prob)
    for i in 1:length(p)
        if prob < p[i]
            return(i)
        elseif i==length(p)
            return(i)
        end #fin if
    end #fin for
end #fin choix_alpha
===#


#===
# DM2_2 avant édit:
include("DM1_1.jl")
include("DM2_1.jl")
include("DM1_2.jl")

#======================================================================#
function ReactiveGRASP(
    matrix, #matrice de taille m*n representant les condion de notre SPP
    cost, #liste des couts de taille n de notre SPP
    n, #nombre de variable de notre SPP
    m, #nombre de condtion de notre SPP
    ite, #nombre de tirage au sort de alpha avant recalcul des probabilités
    coupe, #nombre de coupe du segment [0,1], si on à pas de liste alpha personalisé
    alphaset, #permet de passer une liste de alpha personnelle
    temps #ressource en seconde alloué a notre reactive-GRASP
    )

    #initialisation
    (p,nb_iteration,z_cumul,zBest,zWorst) = intialiser(matrix,cost, n, m, ite, coupe, alphaset)
    liste_alpha = deepcopy(p)
    evol_p=Float64[]
    t=time()
    z_global = zeros(Int64, length(p))
    ite_global = zeros(Int64, length(p))
    nb_boucle = 0

    while (time()-t <= temps)
        append!(evol_p,p) #MaJ de notre historique de probabilité
        cpt=1
        nb_boucle += 1
        #On s'assure que chaque alpha s'exprime au moins une fois.
        for i in 1:length(p)
            (SOL,z, crts) = GRASP(cost, matrix, n, m, liste_alpha[i])
            (SOL, z) = exchange1_1(SOL,n,m,cost,crts,matrix)
            z_cumul[i] += z
            if z < zWorst
                zWorst = z
            elseif z > zBest
                zBest = z
            end
        end #fin for
        while (cpt <= ite)
            #Selection du alpha
            prob = rand(Float64)
            alpha_choisit = choix_alpha(p,prob)
            #On lance GRASP avec cet alpha
            (SOL, z, crts) = GRASP(cost, matrix, n, m, liste_alpha[alpha_choisit])
            #Amelioration
            (SOL, z) = exchange1_1(SOL,n,m,cost,crts,matrix)
            #Réinitialisation
            nb_iteration[alpha_choisit] += 1
            z_cumul[alpha_choisit] += z
            #Mise à jours
            if z > zBest
                zBest = z
            end #fin if
            if z < zWorst
                zWorst = z
            end #fin if
            #Incrément
            cpt = cpt+1
        end #Fin while
        #On recalcul les probabilitées
        recalcul_p!(p,z_cumul,zBest,zWorst,nb_iteration,evol_p)
        #On sovegarde le nombre d'itération et les valeurs de z
        for i in 1:length(p)
            z_global[i] = z_global[i] + z_cumul[i]
            ite_global[i] = ite_global[i] + nb_iteration[i]
        end

        nb_iteration = ones(Int64, length(p))
        z_cumul = zeros(Int64, length(p))

    end #fin while
    #Calcul de aAvg
    moyenne_global=zeros(Float64,length(p))
    for i in 1:length(p)
        moyenne_global[i] = z_global[i]/ite_global[i]
    end
    zAvg = sum(moyenne_global)/length(p)

    println("zBest: ", zBest,"   zAvg:  ", zAvg, "    zWorst: ", zWorst , " nombre de recalcul de p: ", nb_boucle)
#    println(evol_p) #A decommenter si l'on souhaite afficher l'évolution des probabilités
    return(evol_p)
end #fin reactive-GRASP

#=======================================#
function intialiser(matrix, cost, n, m, ite, coupe, alphaset) #initialisation des variables
    p = Float64[]
    if alphaset == 0 #On verifie si on posséde ou non un set
        if coupe >= 1 #On verifie que les coupes sont admissibles
            for i in 1:coupe
                push!(p,i/coupe)
            end #fin for
        end #fin if
    else #on initialise le alphaset
        p = alphaset
    end #fin if

    nb_iteration = ones(Int64, length(p)) #On s'assurera plus tard que tous les alpha s'esprime au moins une fois
    z_cumul = zeros(Int64, length(p)) #Sera une liste de stockage pour le recalcul des probabilités

    (SOL,z) =Glouton(cost, matrix, n, m) #Initialisation d'une solution de base
    zBest = z
    zWorst = z

    return(p,nb_iteration,z_cumul,zBest,zWorst)
end #fin initialiser

#=======================================#
function recalcul_p!(p,z_cumul,zBest,zWorst,nb_iteration,evol_p)
    #initialisation
    q=zeros(Float64,length(p))
    somme_q=0

    for i in 1:length(p)
        moyenne = (z_cumul[i]/nb_iteration[i])
        q[i] = (moyenne-zWorst)/(zBest-zWorst)
        somme_q += q[i]
    end
    for i in 1:length(q)
        p[i] = q[i]/somme_q
    end

    for i in 2:length(p)-1 #On additionne les proabilités entre elles
        p[i] += p[i-1]
    end
    p[length(p)] = 1 #On s'assure qu'il n'y ai pas d'erreur d'arrondie pour 1
end #fin recalcul_p!

#===========================================#
function choix_alpha(p,prob)
    for i in 1:length(p)
        if prob < p[i]
            return(i)
        elseif i==length(p)
            return(i)
        end #fin if
    end #fin for
end #fin choix_alpha


===#


#==
#DM2_2 après edition

include("DM1_1.jl")
include("DM2_1.jl")
include("DM1_2.jl")

#======================================================================#
function ReactiveGRASP(
    matrix, #matrice de taille m*n representant les condion de notre SPP
    cost, #liste des couts de taille n de notre SPP
    n, #nombre de variable de notre SPP
    m, #nombre de condtion de notre SPP
    ite, #nombre de tirage au sort de alpha avant recalcul des probabilités
    coupe, #nombre de coupe du segment [0,1], si on à pas de liste alpha personalisé
    alphaset, #permet de passer une liste de alpha personnelle
    temps #ressource en seconde alloué a notre reactive-GRASP
    )

    #initialisation
    (p,nb_iteration,z_cumul,zBest,zWorst) = intialiser(matrix,cost, n, m, ite, coupe, alphaset)
    liste_alpha = deepcopy(p)
    evol_p=Float64[]
    t=time()
    z_global = zeros(Int64, length(p))
    ite_global = zeros(Int64, length(p))
    nb_boucle = 0
#    println("liste alpha1: ", liste_alpha)

    while (time()-t <= temps)
        append!(evol_p,p) #MaJ de notre historique de probabilité
        cpt=1
        nb_boucle += 1
        #On s'assure que chaque alpha s'exprime au moins une fois.
        for i in 1:length(p)
            (SOL,z, crts) = GRASP(cost, matrix, n, m, liste_alpha[i])
            (SOL, z) = exchange1_2(SOL,n,m,cost,crts,matrix)
            z_cumul[i] += z
            if z < zWorst
                zWorst = z
            elseif z > zBest
                zBest = z
            end
        end #fin for
        while (cpt <= ite)
            #Selection du alpha
            prob = rand(Float64)
            alpha_choisit = choix_alpha(p,prob)
            #On lance GRASP avec cet alpha
            (SOL, z, crts) = GRASP(cost, matrix, n, m, liste_alpha[alpha_choisit])
            #Amelioration
            (SOL, z) = exchange1_2(SOL,n,m,cost,crts,matrix)
            #Réinitialisation
            nb_iteration[alpha_choisit] += 1
            z_cumul[alpha_choisit] += z
            #Mise à jours
            if z > zBest
                zBest = z
            end #fin if
            if z < zWorst
                zWorst = z
            end #fin if
            #Incrément
            cpt = cpt+1
        end #Fin while
        #On recalcul les probabilitées
        recalcul_p!(p,z_cumul,zBest,zWorst,nb_iteration,evol_p)
        #On sovegarde le nombre d'itération et les valeurs de z
        for i in 1:length(p)
            z_global[i] = z_global[i] + z_cumul[i]
            ite_global[i] = ite_global[i] + nb_iteration[i]
        end

        nb_iteration = ones(Int64, length(p))
        z_cumul = zeros(Int64, length(p))

    end #fin while
    #Calcul de aAvg
    moyenne_global=zeros(Float64,length(p))
    for i in 1:length(p)
        moyenne_global[i] = z_global[i]/ite_global[i]
    end
    zAvg = sum(moyenne_global)/length(p)

    println("zBest: ", zBest,"   zAvg:  ", zAvg, "    zWorst: ", zWorst , " nombre de recalcul de p: ", nb_boucle)
#    println(evol_p) #A decommenter si l'on souhaite afficher l'évolution des probabilités
    return(evol_p)
end #fin reactive-GRASP

#=======================================#
function intialiser(matrix, cost, n, m, ite, coupe, alphaset) #initialisation des variables
    p = Float64[]
    if alphaset == 0 #On verifie si on posséde ou non un set
        if coupe >= 1 #On verifie que les coupes sont admissibles
            for i in 1:coupe
                push!(p,i/coupe)
            end #fin for
        end #fin if
    else #on initialise le alphaset
        p = alphaset
    end #fin if

    nb_iteration = ones(Int64, length(p)) #On s'assurera plus tard que tous les alpha s'esprime au moins une fois
    z_cumul = zeros(Int64, length(p)) #Sera une liste de stockage pour le recalcul des probabilités

    (SOL,z) =Glouton(cost, matrix, n, m) #Initialisation d'une solution de base
    zBest = z
    zWorst = z

    return(p,nb_iteration,z_cumul,zBest,zWorst)
end #fin initialiser

#=======================================#
function recalcul_p!(p,z_cumul,zBest,zWorst,nb_iteration,evol_p)
    #initialisation
    q=zeros(Float64,length(p))
    somme_q=0

    for i in 1:length(p)
        moyenne = (z_cumul[i]/nb_iteration[i])
        q[i] = (moyenne-zWorst)/(zBest-zWorst)
        somme_q += q[i]
    end
    for i in 1:length(q)
        p[i] = q[i]/somme_q
    end

    for i in 2:length(p)-1 #On additionne les proabilités entre elles
        p[i] += p[i-1]
    end
    p[length(p)] = 1 #On s'assure qu'il n'y ai pas d'erreur d'arrondie pour 1
end #fin recalcul_p!

#===========================================#
function choix_alpha(p,prob)
    for i in 1:length(p)
        if prob < p[i]
            return(i)
        elseif i==length(p)
            return(i)
        end #fin if
    end #fin for
end #fin choix_alpha
==#


#==
#DM2_2 avant édition
include("DM1_1.jl")
include("DM2_1.jl")
include("DM1_2.jl")

#======================================================================#
function ReactiveGRASP(
    matrix, #matrice de taille m*n representant les condion de notre SPP
    cost, #liste des couts de taille n de notre SPP
    n, #nombre de variable de notre SPP
    m, #nombre de condtion de notre SPP
    ite, #nombre de tirage au sort de alpha avant recalcul des probabilités
    coupe, #nombre de coupe du segment [0,1], si on à pas de liste alpha personalisé
    alphaset, #permet de passer une liste de alpha personnelle
    temps #ressource en seconde alloué a notre reactive-GRASP
    )

    #initialisation
    (p,nb_iteration,z_cumul,zBest,zWorst) = intialiser(matrix,cost, n, m, ite, coupe, alphaset)
    evol_p=Float64[]
    t=time()
    z_global = zeros(Int64, length(p))
    ite_global = zeros(Int64, length(p))
    nb_boucle = 0

    while (time()-t <= temps)
        append!(evol_p,p) #MaJ de notre historique de probabilité
        cpt=1
        nb_boucle += 1
        #On s'assure que chaque alpha s'exprime au moins une fois.
        for i in 1:length(p)
            (SOL,z, crts) = GRASP(cost, matrix, n, m, p[i])
            z_cumul[i] += z
            if z < zWorst
                zWorst = z
            elseif z > zBest
                zBest = z
            end
        end #fin for
        while (cpt <= ite)
            #Selection du alpha
            prob = rand(Float64)
            alpha_choisit = choix_alpha(p,prob)
            #On lance GRASP avec cet alpha
            (SOL, z, crts) = GRASP(cost, matrix, n, m, p[alpha_choisit])
            #Amelioration
            (SOL, z) = exchange1_1(SOL,n,m,cost,crts,matrix)
            #Réinitialisation
            nb_iteration[alpha_choisit] += 1
            z_cumul[alpha_choisit] += z
            #Mise à jours
            if z > zBest
                zBest = z
            end #fin if
            if z < zWorst
                zWorst = z
            end #fin if
            #Incrément
            cpt = cpt+1
        end #Fin while
        #On recalcul les probabilitées
        recalcul_p!(p,z_cumul,zBest,zWorst,nb_iteration,evol_p)
        #On sovegarde le nombre d'itération et les valeurs de z
        for i in 1:length(p)
            z_global[i] = z_global[i] + z_cumul[i]
            ite_global[i] = ite_global[i] + nb_iteration[i]
        end

        nb_iteration = ones(Int64, length(p))
        z_cumul = zeros(Int64, length(p))

    end #fin while
    #Calcul de aAvg
    moyenne_global=zeros(Float64,length(p))
    for i in 1:length(p)
        moyenne_global[i] = z_global[i]/ite_global[i]
    end
    zAvg = sum(moyenne_global)/length(p)

    println("zBest: ", zBest,"   zAvg:  ", zAvg, "    zWorst: ", zWorst , " nombre de recalcul de p: ", nb_boucle)
#    println(evol_p) #A decommenter si l'on souhaite afficher l'évolution des probabilités
    return(evol_p)
end #fin reactive-GRASP

#=======================================#
function intialiser(matrix, cost, n, m, ite, coupe, alphaset) #initialisation des variables
    p = Float64[]
    if alphaset == 0 #On verifie si on posséde ou non un set
        if coupe >= 1 #On verifie que les coupes sont admissibles
            for i in 1:coupe
                push!(p,i/coupe)
            end #fin for
        end #fin if
    else #on initialise le alphaset
        p = alphaset
    end #fin if

    nb_iteration = ones(Int64, length(p)) #On s'assurera plus tard que tous les alpha s'esprime au moins une fois
    z_cumul = zeros(Int64, length(p)) #Sera une liste de stockage pour le recalcul des probabilités

    (SOL,z) =Glouton(cost, matrix, n, m) #Initialisation d'une solution de base
    zBest = z
    zWorst = z

    return(p,nb_iteration,z_cumul,zBest,zWorst)
end #fin initialiser

#=======================================#
function recalcul_p!(p,z_cumul,zBest,zWorst,nb_iteration,evol_p)
    #initialisation
    q=zeros(Float64,length(p))
    somme_q=0
#    println("p:  ", p)
#    println("zcummul:  ", z_cumul)
#    println("nb_ite;   ", nb_iteration)
#    println("zBest: ", zBest, "    zWorst: ", zWorst)

    for i in 1:length(p)
        moyenne = (z_cumul[i]/nb_iteration[i])
        q[i] = (moyenne-zWorst)/(zBest-zWorst)
#        println(i, " moyenne: ", moyenne, "   q[i] : " , q[i])
        somme_q += q[i]
    end
#    println("--------------------")
    for i in 1:length(q)
        p[i] = q[i]/somme_q
    end

    for i in 2:length(p)-1 #On additionne les proabilités entre elles
        p[i] += p[i-1]
    end
    p[length(p)] = 1 #On s'assure qu'il n'y ai pas d'erreur d'arrondie pour 1
end #fin recalcul_p!

#===========================================#
function choix_alpha(p,prob)
    for i in 1:length(p)
        if prob < p[i]
            return(i)
        elseif i==length(p)
            return(i)
        end #fin if
    end #fin for
end #fin choix_alpha
==#

#=
function exchange1_1(solution,n,m,couts,crts,matrix)
    x_best = Solution(solution,calculz(solution,couts,n))
    # notre boucle k
    for i in 1:n
        if  x_best.x[i]  == 1
            x_prime = deepcopy(x_best)
            x_prime.x[i] = 0
            x_prime.objectif = calculz(x_prime.x,couts,n)
            # notre boucle p
            for j = 1:n
                if x_prime.x[j] == 0 && j != i # j != i car ça sers à rien de remettre une variable enlevée
                    x_seconde = deepcopy(x_prime)
                    x_seconde.x[j] = 1
                    x_seconde.objectif = calculz(x_prime.x,couts,n)
                    #on met à jour notre meilleur Solution
                    if x_seconde.objectif > x_best.objectif
                        x_best = deepcopy(x_seconde)
                    end
                end
            end
        end
    end
    #x,objectif= Solution.x
    return(x_best.x,x_best.objectif)
end
=#



#Reactive grasp final

#=
include("DM1_1.jl")
include("DM2_1.jl")
function ReactiveGRASP(matrix,cost, n, m, ite, coupe,temps)
#    println("^^^^^^^^ Debut R-GRASP ^^^^^^^^")
    #initialisation
    (p,nb_iteration,z_cumul,zBest,zWorst) = intialiser(matrix,cost, n, m, ite, coupe)
#    println("valeurs initiales: ")
#    println("p: ", p)
#    println("nb_iteration: ", nb_iteration)
#    println("z_cumul: ", z_cumul)
#    println("zBest: ", zBest , "  zWorst: ", zWorst)
    evol_p=Float64[]
    t=time()
    while (time()-t <= temps)
        cpt = 1
        append!(evol_p,p)
        while (cpt <= ite)
            for i in 1:length(p)
                (SOL,z) = GRASP(cost, matrix, n, m, p[i])
                z_cumul[i] += z
            end
            cpt = cpt+1
            prob=rand(Float64)
            alpha_choisit = choix_alpha(p,prob)
#            println("alpha_choisit: ", alpha_choisit, "  p: ", p)
            (SOL,z) = GRASP(cost, matrix, n, m, p[alpha_choisit])
            nb_iteration[alpha_choisit] += 1
            z_cumul[alpha_choisit] += z
            if z > zBest
                zBest = z
            end
            if z < zWorst
                zWorst = z
            end
#            println(" ============= \n ite: ",cpt)
        end
#        println("zBest: ", zBest, "   zWorst: ", zWorst)
#        println("  z_cumul: ",z_cumul)
#        println( "    nb_iteration : ", nb_iteration , "    p: ", p)
        recalcul_p!(p,z_cumul,zBest,zWorst,nb_iteration,evol_p)
        nb_iteration = ones(Int64, length(p))
        z_cumul = zeros(Int64, length(p))
    end
    println("^^^^^^^^ Fin ReactiveGRASP ^^^^^^^^")
    println("zBest: ", zBest, "    zWorst: ", zWorst)
    println(evol_p)
end
#=======================================#
function intialiser(matrix,cost, n, m, ite, coupe)
    p = Float64[]
    for i in 1:coupe
        push!(p,i/coupe)
    end
    nb_iteration = ones(Int64, length(p))
    z_cumul = zeros(Int64, length(p))
    (SOL,z) =Glouton(cost, matrix, n, m)
    zBest = z
    zWorst = z
    return(p,nb_iteration,z_cumul,zBest,zWorst)
end
#=======================================#
function recalcul_p!(p,z_cumul,zBest,zWorst,nb_iteration,evol_p)
    q=zeros(Float64,length(p))
    somme_q=0
#    println("q: ", q)
#    println("nb_iteration: ", nb_iteration)
    for i in 1:length(p)
#        println("q: ", q, "   i:", i)
#        if nb_iteration[i]!=0
#            println("z_cumul[i]: ", z_cumul[i],"   nb_iteration[i]: ", nb_iteration[i] )
            moyenne=(z_cumul[i]/nb_iteration[i])
#            println("moyenne: ", moyenne)
#        else
#            moyenne=0
#        end
#        if moyenne>0
            q[i]=(moyenne-zWorst)/(zBest-zWorst)
#            println("q[i]: ", q[i])
#        else
#            q[i]= zWorst/(zBest-zWorst)
#        end
        somme_q+=q[i]
    end
#    println("q: ", q, "      somme_q", somme_q)
    for i in 1:length(q)
        p[i]=q[i]/somme_q
    end
    for i in 2:length(p)-1
        p[i]+=p[i-1]
    end
    p[length(p)]=1
#    println("p: ", p)
end
#=======================================#
function choix_alpha(p,prob)
    for i in 1:length(p)
        if prob < p[i]
            return(i)
        elseif i==length(p)
            return(i)
        end
    end
end
=#
#=
#DM2_1
# =========================================================================== #
# =========================================================================== #
#Implementing an x0 viable solution huristic with a gluton method
#receiving an array of lenght()=m , a matrix of size m*n and thoose size
#returing a Bool array of lenght=n
#Asked question:
#Mettre en place une heuristique de construction d’une x0 réalisable.
function RandomGlouton(cost, matrix, n, m, alpha)
    #Creating a set of lines that will be avaluated
    actif= zeros(Bool, m) #if actif[j]=0 the line will be avaluated
    stop1= ones(Bool,m)
    #Creation the an array of activated variables
    varactive = ones(Bool, n)
    stop2= zeros(Bool , n)
#    println("\n varactive: ", varactive, "\n stop2: ", stop2)
    #creating my utility array for my m variables
    util = zeros(Float64, n)
    #initialisation de la Solution
    SOL = zeros(Float64, n)
#    println( "\n Matrix: ", matrix, "\n Cost: ", cost,"\n n= ", n, "   m= ", m,"\n actif: ", actif, "\n stop: ", stop1, "\n util: ", util, "\n SOL: ", SOL, "\n \n")
    ite = 0
    #Création de la solution
    while actif!=stop1 && varactive!=stop2
#      println("\n ++++++++++++++++++++++++++++++++++++++++")
#      println("\n itération: ", ite)
      #println("\n actif : ", actif, "\n stop1 : " , "\n varactive : " , varactive , "\n stop2 : ")
#      println("\n ++++++++++++++++++++++++++++++++++++++++")
        #Foction d'utilité
        util = Utilite(cost, matrix, actif, n, m , varactive, stop1, stop2)
        #Choix parmis les candidats de util
#        PosCandidat::Int64
#        PosCandidat = PosMax(util,n)
        PosCandidat::Int64 = choixcandidat(util, alpha)
        #On ajoute le candidat à la solution
        SOL[PosCandidat] = 1
        #Desactive! le candidat selectionné
        Desactive!(PosCandidat, matrix, actif, m, varactive,n)
        ite=ite+1
    end
    #println(calculz(SOL,cost,n))
    #return(SOL)
    Z = calculz(SOL,cost,n)
    println("Solution avant améliration: " , Z)
#    return(SOL, actif, Z)
    return(SOL, Z)
end
# =========================================================================== #
#Detremine an utility  based on an active (actif) set of matrix's lines
function Utilite(cost, matrix, actif, n, m , varactive, stop1, stop2)
#    println("==========================")
    util = zeros(Float64, n) #réinitialisation du vecteur
    #On each column of matrix
    for j=1:n
            if varactive[j] == 1
                    #For each line
                    for i=1:m
                        #checking if the line is active
                        if actif[i]==0 #&& i <= m
                            K=matrix[i,j]
                            util[j]=util[j]+K
#                            println("====== \n", "i: ", i ,"    j: ", j , "   k: ", K )
#                            println("\n varactive: ", varactive)
#                            println("\n actif : ", actif)
#                            println("\n util : ", util)
                        end
                    end
                # dividing the number if iterations of the variable j by its cost (not a zero)
                if util[j]!=false #On évide de divisé par 0...
#                    println("\n util avant modif: ", util)
                    util[j] =  cost[j] / util[j]
#                    println("\n util après modif: ", util)
                else
                    varactive[j] = 0
                end
            end
    end
#    println("\n Util: ", util)
#    println("\n \n ===================Utilite fini =============")
    return util
end
# =========================================================================== #
#=
function PosMax(util,n) #On choisie un candidat parmie les différents coûts, par ordre lexicographique
#println("%%%%%%%%%%%%%%%%%%%%")
#    Pos::Int64
    Pos=0
    ValCan=0.0
    for i=1:n
        if util[i] > ValCan
            ValCan = util[i]
            Pos = i
        end
    end
    #println("\n \n %%%%%% Pos max fini %%%%% \n pos: ", Pos)
    return Pos
end
=#
# =========================================================================== #
function Desactive!(PosCandidat, matrix, actif, m , varactive , n) #On désactive les lignes où est le candidat
#println("\n======================= desactive ==============================")
#println("~~~~~~~~~~~~~~~~~~~~~~~~")
    for i=1:m
#        println("\n Boucle i: ", i)
        if matrix[i,PosCandidat] == 1
#            println("\n If matrix[i,PosCandidat] == 1: " , matrix[i,PosCandidat])
            actif[i] = 1
#            println("\n actif[i] = 1: ", actif[i])
            for j=1:n
#                println("\n for j=1:n ; j: ", j)
                if matrix[i,j] ==1
#                    println("\n if matrix[i,j] ==1 :", matrix[i,j])
                    varactive[j] = 0
#                    println("\n varactive[j] = 0: ", varactive)
                end
            end
        end
    end
#    println("\n \n ~~~~~~~~~Desactive fini! ~~~~~~~\n ")
#    println("varactive: ", varactive)
#    println("actif: ", actif)
end
#=========================================================================#
function calculz(x,costs,m)
    z = 0
    for i in 1:m
        z+= x[i]*costs[i]
    end
    return z
end
#==========================================#
function choixcandidat(util, alpha)
    max = maximum(util)
    min = minimum(util)
#    Rut = Array{Float64}[]
    Rut = Float64[]
#    println("util: ", util, "\n type de util: ", typeof(util))
#    println("min: ", min, " max: ", max, " Rut: ", Rut)
    cpt::Int=1
    for i in 1:length(util)
#        println("debut for: ", i)
        if util[i]>= min+alpha*(max-min)
            push!(Rut,i)
        end
    end
    prob=rand(1:length(Rut))
#    println("fini, Rut: ", Rut, " Prob: ", prob)
    return(Rut[prob])
end
=#

#==
#Version 0
function choixcandidat(util, alpha)
    max = maximum(util)
    min = minimum(util)
#    Rut = Array{Float64}[]
    Rut = Float64[]
#    println("util: ", util, "\n type de util: ", typeof(util))
#    println("min: ", min, " max: ", max, " Rut: ", Rut)
    cpt::Int=1
    for i in 1:length(util)
#        println("debut for: ", i)
        if util[i]>= min+alpha*(max-min)
            push!(Rut,util[i])
        end
    end
    prob=rand(1:length(Rut))
#    println("fini, Rut: ", Rut, " Prob: ", prob)
    return(Rut[prob])
end
=#
#=
#Test run
z = Array{Float64}(undef, 42)
alpha = 0.9
println("z: ", z, " alpha : ", alpha)
cand=choixcandidat(z,alpha)
println("\n candidat choisit: ",cand)
==#
#=========================#
#=
DM1_1
# =========================================================================== #
# =========================================================================== #
#Implementing an x0 viable solution huristic with a gluton method
#receiving an array of lenght()=m , a matrix of size m*n and thoose size
#returing a Bool array of lenght=n
#Asked question:
#Mettre en place une heuristique de construction d’une x0 réalisable.
function Glouton(cost, matrix, n, m)
    #Creating a set of lines that will be avaluated
    actif= zeros(Bool, m) #if actif[j]=0 the line will be avaluated
    stop1= ones(Bool,m)
    #Creation the an array of activated variables
    varactive = ones(Bool, n)
    stop2= zeros(Bool , n)
#    println("\n varactive: ", varactive, "\n stop2: ", stop2)
    #creating my utility array for my m variables
    util = zeros(Float64, n)
    #initialisation de la Solution
    SOL = zeros(Float64, n)
#    println( "\n Matrix: ", matrix, "\n Cost: ", cost,"\n n= ", n, "   m= ", m,"\n actif: ", actif, "\n stop: ", stop1, "\n util: ", util, "\n SOL: ", SOL, "\n \n")
    ite = 0
    #Création de la solution
    while actif!=stop1 && varactive!=stop2
#      println("\n ++++++++++++++++++++++++++++++++++++++++")
#      println("\n itération: ", ite)
      #println("\n actif : ", actif, "\n stop1 : " , "\n varactive : " , varactive , "\n stop2 : ")
#      println("\n ++++++++++++++++++++++++++++++++++++++++")
        #Foction d'utilité
        util = Utilite(cost, matrix, actif, n, m , varactive, stop1, stop2)
        #Choix parmis les candidats de util
#        PosCandidat::Int64
        PosCandidat = PosMax(util,n)
        #On ajoute le candidat à la solution
        SOL[PosCandidat] = 1
        #Desactive! le candidat selectionné
        Desactive!(PosCandidat, matrix, actif, m, varactive,n)
        ite=ite+1
    end
    #println(calculz(SOL,cost,n))
    #return(SOL)
    Z = calculz(SOL,cost,n)
    println("Solution avant améliration: " , Z)
#    return(SOL, actif, Z)
    return(SOL, Z)
end
# =========================================================================== #
#Detremine an utility  based on an active (actif) set of matrix's lines
function Utilite(cost, matrix, actif, n, m , varactive, stop1, stop2)
#    println("==========================")
    util = zeros(Float64, n) #réinitialisation du vecteur
    #On each column of matrix
    for j=1:n
            if varactive[j] == 1
                    #For each line
                    for i=1:m
                        #checking if the line is active
                        if actif[i]==0 #&& i <= m
                            K=matrix[i,j]
                            util[j]=util[j]+K
#                            println("====== \n", "i: ", i ,"    j: ", j , "   k: ", K )
#                            println("\n varactive: ", varactive)
#                            println("\n actif : ", actif)
#                            println("\n util : ", util)
                        end
                    end
                # dividing the number if iterations of the variable j by its cost (not a zero)
                if util[j]!=false #On évide de divisé par 0...
#                    println("\n util avant modif: ", util)
                    util[j] =  cost[j] / util[j]
#                    println("\n util après modif: ", util)
                else
                    varactive[j] = 0
                end
            end
    end
#    println("\n Util: ", util)
#    println("\n \n ===================Utilite fini =============")
    return util
end
# =========================================================================== #
function PosMax(util,n) #On choisie un candidat parmie les différents coûts, par ordre lexicographique
#println("%%%%%%%%%%%%%%%%%%%%")
#    Pos::Int64
    Pos=0
    ValCan=0.0
    for i=1:n
        if util[i] > ValCan
            ValCan = util[i]
            Pos = i
        end
    end
    #println("\n \n %%%%%% Pos max fini %%%%% \n pos: ", Pos)
    return Pos
end
# =========================================================================== #
function Desactive!(PosCandidat, matrix, actif, m , varactive , n) #On désactive les lignes où est le candidat
#println("\n======================= desactive ==============================")
#println("~~~~~~~~~~~~~~~~~~~~~~~~")
    for i=1:m
#        println("\n Boucle i: ", i)
        if matrix[i,PosCandidat] == 1
#            println("\n If matrix[i,PosCandidat] == 1: " , matrix[i,PosCandidat])
            actif[i] = 1
#            println("\n actif[i] = 1: ", actif[i])
            for j=1:n
#                println("\n for j=1:n ; j: ", j)
                if matrix[i,j] ==1
#                    println("\n if matrix[i,j] ==1 :", matrix[i,j])
                    varactive[j] = 0
#                    println("\n varactive[j] = 0: ", varactive)
                end
            end
        end
    end
#    println("\n \n ~~~~~~~~~Desactive fini! ~~~~~~~\n ")
#    println("varactive: ", varactive)
#    println("actif: ", actif)
end
#=========================================================================#
function calculz(x,costs,m)
    z = 0
    for i in 1:m
        z+= x[i]*costs[i]
    end
    return z
end
=#

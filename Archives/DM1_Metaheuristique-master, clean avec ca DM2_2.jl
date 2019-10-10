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

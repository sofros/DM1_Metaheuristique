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
    coupe, #nombre de coupe de notre segmen [0,1], et le nombre de alpha
    alphaset, #permet de passer une liste de alpha personnelle
    temps #ressource en seconde alloué a notre reactive-GRASP
    )

    #initialisation
    (p,nb_iteration,z_cumul,zBest,zWorst) = intialiser(matrix,cost, n, m, ite, coupe, alphaset)
    evol_p=Float64[]
    t=time()

    while (time()-t <= temps)
        append!(evol_p,p) #MaJ de notre historique de probabilité
        cpt=1
        while (cpt <= ite)
            #On s'assure que chaque alpha s'exprime au moins une fois.
            for i in 1:length(p)
                (SOL,z, crts) = GRASP(cost, matrix, n, m, p[i])
                z_cumul[i] += z
            end #fin for
            #Selection du alpha
            prob = rand(Float64)
            alpha_choisit = choix_alpha(p,prob)
            #
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

        recalcul_p!(p,z_cumul,zBest,zWorst,nb_iteration,evol_p)
        nb_iteration = ones(Int64, length(p))
        z_cumul = zeros(Int64, length(p))

    end #fin while
    println("zBest: ", zBest, "    zWorst: ", zWorst)
    #println(evol_p) #A decommenter si l'on souhaite afficher l'évolution des probabilités
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

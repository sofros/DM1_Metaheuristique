include("DM1_1.jl")
include("DM2_1.jl")
include("DM1_2_corrige.jl")
#=========================================#
function ReactiveGRASP( #Utilisation du Reactive GRASP
    matrix, #Un matrice de taille n*m qui représente les conditions
    cost, #Une liste des couts de chaque variable
    n, #nombre de variables
    m, #nombre de contraintes
    ite, #on tierera ce nombre avant de recalculer des probabilités de chaque alpha
    coupe, #Le nombre de coupe du segment [0,1], nous permet de construire nos alpha
    alphaset,
    temps #La ressource en temps en seconde alloué
    )

    #initialisation
    (p,nb_iteration,z_cumul,zBest,zWorst) = intialiser(matrix,cost, n, m, ite, coupe, alphaset)

    evol_p=Float64[] #liste qui stokera l'évolution de nos probabilités au fur et à mesure des itérations.
    t=time()
    cpt = 1

    while (time()-t <= temps) #Condtion sur les ressources en temps
        append!(evol_p,p)
        while (cpt <= ite)


            for i in 1:length(p) #On s'assure que chaque probabilité se soit exprimé au moins une fois
                (SOL,z, crts) = GRASP(cost, matrix, n, m, p[i])
                z_cumul[i] += z
            end

            prob=rand(Float64)
            #prob = rand(1:length(p))

            alpha_choisit = choix_alpha(p,prob)
            (SOL, z, crts) = GRASP(cost, matrix, n, m, p[alpha_choisit])
            #(SOL, z, crts) = GRASP(cost, matrix, n, m, p[prob])

            #Amelioration
            (SOL, z) = exchange1_1(SOL,n,m,cost,crts,matrix)

            nb_iteration[alpha_choisit] += 1
            #nb_iteration[prob] += 1
            z_cumul[alpha_choisit] += z
            #z_cumul[prob] += z

            if z > zBest
                zBest = z
            end

            if z < zWorst
                zWorst = z
            end

            cpt = cpt+1 #Compteur du nombre d'itération
        end

        recalcul_p!(p,z_cumul,zBest,zWorst,nb_iteration,evol_p)
        nb_iteration = ones(Int64, length(p))
        z_cumul = zeros(Int64, length(p))

    end
    println("zBest: ", zBest, "    zWorst: ", zWorst)
    println(evol_p) #A commenter si on ne souhaite pas voir la liste d'évolution des probabilités
    return(evol_p)
end

#=======================================#
function intialiser(matrix,cost, n, m, ite, coupe, alphaset) #initialisationd des variables

    p = Float64[]
    if alphaset == 0
        for i in 1:coupe
            push!(p,i/coupe)
        end
    else
        p = alphaset
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

    for i in 1:length(p)

        moyenne=(z_cumul[i]/nb_iteration[i])
        q[i]=(moyenne-zWorst)/(zBest-zWorst)
        somme_q+=q[i]

    end

    for i in 1:length(q)
        p[i]=q[i]/somme_q
    end

    for i in 2:length(p)-1
        p[i]+=p[i-1]
    end
    p[length(p)]=1

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

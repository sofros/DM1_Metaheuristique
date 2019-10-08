include("DM1_1.jl")
include("DM2_1.jl")
include("DM1_2_corrige.jl")

function ReactiveGRASP(matrix,cost, n, m, ite, coupe,temps)

    #initialisation
    (p,nb_iteration,z_cumul,zBest,zWorst) = intialiser(matrix,cost, n, m, ite, coupe)

    evol_p=Float64[]
    t=time()

    while (time()-t <= temps)
        cpt = 1
        append!(evol_p,p)
        while (cpt <= ite)
            for i in 1:length(p)
                (SOL,z, crts) = GRASP(cost, matrix, n, m, p[i])
                z_cumul[i] += z
            end

            cpt = cpt+1

            prob=rand(Float64)

            alpha_choisit = choix_alpha(p,prob)
            (SOL, z, crts) = GRASP(cost, matrix, n, m, p[alpha_choisit])
            println("================")
            println(z)

            #Amelioration
            (SOL, z) = exchange1_2(SOL,n,m,cost,crts,matrix)


            nb_iteration[alpha_choisit] += 1
            z_cumul[alpha_choisit] += z

            if z > zBest
                zBest = z
            end

            if z < zWorst
                zWorst = z
            end

        end

        recalcul_p!(p,z_cumul,zBest,zWorst,nb_iteration,evol_p)
        nb_iteration = ones(Int64, length(p))
        z_cumul = zeros(Int64, length(p))

    end
#    println("^^^^^^^^ Fin ReactiveGRASP ^^^^^^^^")
    println("zBest: ", zBest, "    zWorst: ", zWorst)
    println(evol_p)
    return(evol_p)
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

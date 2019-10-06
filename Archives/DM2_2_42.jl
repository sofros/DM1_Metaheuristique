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

        println("zBest: ", zBest, "   zWorst: ", zWorst, "    nb_iteration : ", nb_iteration , "    p: ", p)
        recalcul_p!(p,z_cumul,zBest,zWorst,nb_iteration,evol_p)


#        println("\n nb_iteration avant reset", nb_iteration)
        nb_iteration = zeros(Int64, length(p))
        z_cumul = zeros(Int64, length(p))
#        println("\n nb_iteration apre reset", nb_iteration)

    end
    println(evol_p)
end

#=======================================#

function intialiser(matrix,cost, n, m, ite, coupe)

    p = Float64[]
    for i in 1:coupe
        push!(p,i/coupe)
    end

    nb_iteration = zeros(Int64, length(p))


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
        if nb_iteration[i]!=0
            println("z_cumul[i]: ", z_cumul[i],"   nb_iteration[i]: ", nb_iteration[i] )
            moyenne=(z_cumul[i]/nb_iteration[i])
           println("moyenne: ", moyenne)
        else
            moyenne=0
        end
        if moyenne>0
            q[i]=(moyenne-zWorst)/(zBest-zWorst)
#            println("q[i]: ", q[i])

        else
            q[i]= zWorst/(zBest-zWorst)
        end
        somme_q+=q[i]

    end
#    println("q: ", q, "      somme_q", somme_q)

    for i in 1:length(q)
        p[i]=q[i]/somme_q
    end
    println("p avant modif: ", p)
    for i in 2:length(q)
        p[i]+=p[i-1]
    end
    println("p après modif: ", p)
#    println("p: ", p)

end

#=======================================#

function choix_alpha(p,prob)
#    println("p: ", p, "   prob: ", prob)
#    ptemp::Float64=0
    for i in 1:length(p)
#        ptemp = ptemp + p[i]
#        println("ptemp: ",ptemp)
        if p[i]-prob >= 0
            return(i)
        elseif i==length(p)
            return(i)
        end
    end
end

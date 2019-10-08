


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

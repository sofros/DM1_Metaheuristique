function GRASP(cost, matrix, n, m, alpha)
#    println("%%%%%%% Debut GRASP %%%%%%%")
#    println(alpha)

    #Creating a set of lines that will be avaluated
    desactive_condition= zeros(Bool, m) #if desactive_condition[j]=0 the line will be avaluated
    stop1= ones(Bool,m)

    #Creation the an array of activated variables
    variables_actives = ones(Bool, n)
    stop2= zeros(Bool , n)
#    println("\n variables_actives: ", variables_actives, "\n stop2: ", stop2)

    #creating my utility array for my m variables
    util = zeros(Float64, n)

    #initialisation de la Solution
    SOL = zeros(Float64, n)

#    println( "\n Matrix: ", matrix, "\n Cost: ", cost,"\n n= ", n, "   m= ", m,"\n desactive_condition: ", desactive_condition, "\n stop: ", stop1, "\n util: ", util, "\n SOL: ", SOL, "\n \n")

#    ite = 0
    #Création de la solution
    while desactive_condition!=stop1 && variables_actives!=stop2





#      println("\n ++++++++++++++++++++++++++++++++++++++++")
#      println("\n itération: ", ite)
      #println("\n desactive_condition : ", desactive_condition, "\n stop1 : " , "\n variables_actives : " , variables_actives , "\n stop2 : ")
#      println("\n ++++++++++++++++++++++++++++++++++++++++")

        #Foction d'utilité

        util = Utilite(cost, matrix, desactive_condition, n, m , variables_actives, stop1, stop2)



        #Choix parmis les candidats de util
#        PosCandidat::Int64
#        PosCandidat = PosMax(util,n)
        PosCandidat::Int64 = choixcandidat(util, alpha)


        #On ajoute le candidat à la solution
        SOL[PosCandidat] = 1

        #Desactive! le candidat selectionné
        Desactive!(PosCandidat, matrix, desactive_condition, m, variables_actives,n)
#        ite=ite+1
    end
    #println(calculz(SOL,cost,n))
    #return(SOL)
    Z = calculz(SOL,cost,n)
#    println("Solution GRASP: " , Z)
#    return(SOL, desactive_condition, Z)
    return(SOL, Z)

end

# =========================================================================== #

#Detremine an utility  based on an active (desactive_condition) set of matrix's lines
function Utilite(cost, matrix, desactive_condition, n, m , variables_actives, stop1, stop2)
#    println("==========================")
    util = zeros(Float64, n) #réinitialisation du vecteur

    #On each column of matrix
    for j=1:n
            if variables_actives[j] == 1
                    #For each line
                    for i=1:m
                        #checking if the line is active
                        if desactive_condition[i]==0 #&& i <= m
                            K=matrix[i,j]
                            util[j]=util[j]+K
#                            println("====== \n", "i: ", i ,"    j: ", j , "   k: ", K )
#                            println("\n variables_actives: ", variables_actives)
#                            println("\n desactive_condition : ", desactive_condition)
#                            println("\n util : ", util)
                        end
                    end

                # dividing the number if iterations of the variable j by its cost (not a zero)


                if util[j]!=false #On évide de divisé par 0...
#                    println("\n util avant modif: ", util)
                    util[j] =  cost[j] / util[j]
#                    println("\n util après modif: ", util)

                else
                    variables_actives[j] = 0
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

function Desactive!(PosCandidat, matrix, desactive_condition, m , variables_actives , n) #On désactive les lignes où est le candidat
#println("\n======================= desactive ==============================")
#println("~~~~~~~~~~~~~~~~~~~~~~~~")
    for i=1:m
#        println("\n Boucle i: ", i)
        if matrix[i,PosCandidat] == 1
#            println("\n If matrix[i,PosCandidat] == 1: " , matrix[i,PosCandidat])
            desactive_condition[i] = 1
#            println("\n desactive_condition[i] = 1: ", desactive_condition[i])
            for j=1:n
#                println("\n for j=1:n ; j: ", j)
                if matrix[i,j] ==1
#                    println("\n if matrix[i,j] ==1 :", matrix[i,j])
                    variables_actives[j] = 0
#                    println("\n variables_actives[j] = 0: ", variables_actives)
                end
            end
        end
    end
#    println("\n \n ~~~~~~~~~Desactive fini! ~~~~~~~\n ")
#    println("variables_actives: ", variables_actives)
#    println("desactive_condition: ", desactive_condition)
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
#    random_utile = Array{Float64}[]
    random_utile = Float64[]
#    println("util: ", util, "\n type de util: ", typeof(util))
#    println("min: ", min, " max: ", max, " random_utile: ", random_utile)
    cpt::Int=1
    for i in 1:length(util)
#        println("debut for: ", i)
#        println("taille util: ", length(util), "   alpha: ", alpha)
        if util[i]>= min+(alpha*(max-min))
            push!(random_utile,i)
        end
    end
#    println("taille: ", length(random_utile))#, "   max: ", max, "min+(alpha*(max-min): ", min+(alpha*(max-min)))
#=    if length(random_utile)==0
        println("   max: ", max, "   min: ", min , "  min+(alpha*(max-min): ", min+(alpha*(max-min)) , "  alpha :", alpha)
        println("util: ", util)
    end
=#
    prob = rand(1:length(random_utile))
#    println("fini, random_utile: ", random_utile, " Prob: ", prob)
    return(random_utile[prob])
end

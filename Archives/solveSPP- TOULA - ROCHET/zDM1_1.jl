
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

    #Création de la solution
    while actif!=stop1 && varactive!=stop2
#      println("++++++++++++++++++++++++++++++++++++++++")
#      println("\n actif : ", actif, "\n stop1 : " , "\n varactive : " , varactive , "\n stop2 : ")
#      println("++++++++++++++++++++++++++++++++++++++++")

        #Foction d'utilité

        util = Utilite(cost, matrix, actif, n, m , varactive)



        #Choix parmis les candidats de util
        PosCandidat = PosMax(util,n)


        #On ajoute le candidat à la solution
        SOL[PosCandidat] = 1

        #Desactive! le candidat selectionné
        Desactive!(PosCandidat, matrix, actif, m, varactive,n)

    end
    #println(calculz(SOL,cost,n))
    #return(SOL)
    Z = calculz(SOL,cost,n)
    println("Solution avant améliration: " , Z)
    return(SOL, actif, Z)

end

# =========================================================================== #

#Detremine an utility  based on an active (actif) set of matrix's lines
function Utilite(cost, matrix, actif, n, m , varactive)

    util = zeros(Float64, n) #réinitialisation du vecteur

    #On each column of matrix
    for j=1:n

        if varactive[j] == 1

            #For each line
            for i=1:m
                #checking if the line is active
                if actif[i]==0 && i <= m

                    K=matrix[i,j]
                    util[j]=util[j]+K

                end
            end

            # dividing the number if iterations of the variable j by its cost (not a zero)


            if util[j]!=false #On évide de divisé par 0...

                util[j] =  cost[j] / util[j]

            end
        end
    end
    return util
end

# =========================================================================== #

function PosMax(util,n) #On choisie un candidat parmie les différents coûts, par ordre lexicographique

    Pos=1
    ValCan=0.0


    for i=1:n

        if util[i] > ValCan

            ValCan = util[i]
            Pos = i
        end
    end

    return Pos
end


# =========================================================================== #

function Desactive!(PosCandidat, matrix, actif, m , varactive , n) #On désactive les lignes où est le candidat
#println("\n======================= desactive ==============================")
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
end

#=========================================================================#

function calculz(x,costs,m)
    z = 0
    for i in 1:m
        z+= x[i]*costs[i]
    end
    return z
end

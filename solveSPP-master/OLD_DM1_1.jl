
# =========================================================================== #

# =========================================================================== #


#Implementing an x0 viable solution huristic

function Glouton(cost, matrix, n, m)

    #Creating a set of lines that will be avaluated
    actif= zeros(Bool, m) #if actif[j]=0 the line will be avaluated
    stop= ones(Bool,m)

    #creating my utility array for my m variables
    util = zeros(Float64, n)

    #initialisation de la Solution
    SOL = zeros(Float64, n)

    println( "\n Matrix: ", matrix, "\n Cost: ", cost,"\n n= ", n, "   m= ", m,"\n actif: ", actif, "\n stop: ", stop, "\n util: ", util, "\n SOL: ", SOL, "\n \n")


    while actif!=stop
        #Foction d'utilité
        util = Utilite(cost, matrix, actif, n, m)

        println("\n **********************************\n utilité finiiiiiii! :D \n *************************************\n")

        #Choix parmis les candidats de util
        PosCandidat = PosMax(util,n)

        println("\n +++++++++++++ \n PosMax est fini! =) \n Le candidat à la position: ", PosCandidat, "\n Type de de candidat: ", typeof(PosCandidat), "\n +++++++++++++++++ \n")

        #On ajoute le candidat à la solution
        SOL[PosCandidat] = 1

        #Desactive! le candidat selectionné
        Desactive!(PosCandidat, matrix, actif, m)
        println("\n Desactive! est fini avec actif: ", actif,"\n Et SOL: ", SOL,  "\n /////////////////////////////////////////////////")

    end

    return(SOL)

end

# =========================================================================== #

#Detremine an utility  based on an active (actif) set of matrix's lines
function Utilite(cost, matrix, actif, n, m)

    util = zeros(Float64, n)
    i=1
    #On each column of matrix
    for j=1:n
        println("\n \n ============================= \n j= ", j, "  i= ", i, "\n util: ", util, "\n actif[i]: ", actif[i])


        #For each line
        for i=1:m
            println(" actif=", actif, "\n util: ", util)

            #checking if the line is active
            if actif[i]==0

                println("\n i=", i,"  j= ", j, "\n util: ", util)

                K=matrix[i,j]

                println("\n k= ", K)

                util[j]=util[j]+K

                println("\n util: ", util)

            end
        end

        # dividing the number if iterations of the variable j by its cost (not a zero)

        println("\n ***** conversion: ***** \n ", " Util[j]= ", util[j], "  cost[j] = ", cost[j])

        if util[j]!=false

            util[j] =  cost[j] / util[j]

        println(" util= ", util)
        end
    end
    return util
end

# =========================================================================== #

function PosMax(util,n) #On choisie un candidat parmie les différents coûts, par ordre lexicographique

    Pos=1
    ValCan=0.0

    println("\n +++++++++++++++++++\n Debut PosMax\n ", " Pos: ", Pos, " ValCan: ", ValCan, "\n util: ", util, "\n n: ", n, "\n" )

    for i=1:n

        println("\n boucle: ", i)
        if util[i] > ValCan

            ValCan = util[i]
            Pos = i
        end
    end

    println("\n PosMax est fini avec: \n Max: ", ValCan, " Position: ", Pos, "\n")
    return Pos
end


# =========================================================================== #

function Desactive!(PosCandidat, matrix, actif, m) #On désactive les lignes où est le candidat

    println("\n \n ////////////////////////////////////////// \n Debut de Desactive! \n Var check: \n position candidat: ", PosCandidat, "\n matrice : ", matrix, "\n actif: ", actif, "\n n: ", n, "\n")
    for i=1:m
        if matrix[i,PosCandidat] == 1
            actif[i] = 1

        end
    end
    println("Fin Desactive! ")
end


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
    stop= ones(Bool,m)

    #creating my utility array for my m variables
    util = zeros(Float64, n)

    #initialisation de la Solution
    SOL = zeros(Float64, n)


    #Création de la solution
    while actif!=stop

        #Foction d'utilité
        util = Utilite(cost, matrix, actif, n, m)


        #Choix parmis les candidats de util
        PosCandidat = PosMax(util,n)


        #On ajoute le candidat à la solution
        SOL[PosCandidat] = 1

        #Desactive! le candidat selectionné
        Desactive!(PosCandidat, matrix, actif, m)

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


        #For each line
        for i=1:m

            #checking if the line is active
            if actif[i]==0


                K=matrix[i,j]


                util[j]=util[j]+K


            end
        end

        # dividing the number if iterations of the variable j by its cost (not a zero)


        if util[j]!=false #On évide de divisé par 0...

            util[j] =  cost[j] / util[j]

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

    for i=1:m
        if matrix[i,PosCandidat] == 1
            actif[i] = 1

        end
    end
end

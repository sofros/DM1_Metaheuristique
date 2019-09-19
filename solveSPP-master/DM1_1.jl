
# =========================================================================== #

# =========================================================================== #


#Implementing an x0 viable solution huristic

function Glouton(cost, matrix, n, m)

    #Creating a set of lines that will be avaluated
    actif= zeros(Bool, n) #if actif[j]=0 the line will be avaluated
    stop= Ones(Bool,n)

    #creating my utility array for my m variables
    util = zeros(Float, m)

    #initialisation de la Solution
    SOL = zeros(Int, m)


    while actif!=stop
        #Foction d'utilité
        util = Utilite(cost, matrix, actif)

        #Choix parmis les candidats de util
        candidat = Choix(util,m)

        #On ajoute le candidat à la solution
        Sol[candidat] = 1

        #Desactive! le candidat selectionné
        Desactive!(candidat, matrix, actif, n)

    end

    return()

end

# =========================================================================== #

#Detremine an utility  based on an active (actif) set of matrix's lines
function Utilite(cost, matrix, actif)

    util = zeros(Float, m)

    #On each column of matrix
    for j=1:m

        #For each line
        for i=1:n

            #checking if the line is active
            if actif[i]

                util[j]=util[j]+matrix[i,j]

            end

        end

        # dividing the number if iterations of the variable j by its cost (not a zero)
        util[j] = util[j] / cost[j]

    end
    return util
end

# =========================================================================== #

function Choix(util,m) #On choisie un candidat parmie les différents coûts, par ordre lexicographique
    max::Float
    id::Int

    max=util[1]

    for i=2:m
        if util[i] > max
            max = util[i]
            id = i
        end
    end
    return id
end


# =========================================================================== #

function Desactive!(candidat, matrix, actif, n) #On désactive les lignes où est le candidat
    for i=1:n
        if matrix[i,candidat] == 1
            actif[i] = 1
        end
    end
end

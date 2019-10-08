function GRASP(
    cost, #Une array représentant les couts, de taille n
    matrix, #une matrice de taille m*n representant les contrantes
    n, #nombre de variables
    m, #nombbre de contraintes
    alpha # le alpha que nous allons utiliser
     )

     #intitialisation des listes utilisé
     (desactive_condition, stop1, variables_actives, stop2, util, SOL) = initaliser(m,n)

    #Création de la solution
    while desactive_condition!=stop1 && variables_actives!=stop2

        util = Utilite(cost, matrix, desactive_condition, n, m , variables_actives, stop1, stop2) #Foction d'utilité

        PosCandidat::Int64 = choixcandidat(util, alpha) #Choix parmis les candidats de util

        SOL[PosCandidat] = true #On ajoute le candidat à la solution

        Desactive!(PosCandidat, matrix, desactive_condition, m, variables_actives,n) #Desactive! le candidat selectionné et les conditions où il apparait
    end

    Z = calculz(SOL,cost,n)
    return(SOL, Z, desactive_condition)

end

# =========================================================================== #
function initaliser(m,n)
    #Creating a set of lines that will be avaluated
    desactive_condition= zeros(Bool, m) #si desactive_condition[j]=0 la ligne sera évalué
    stop1= ones(Bool,m) #la une condition d'arret, s'active quand toutes les lignes ont été traité

    #Creation the an array of activated variables
    variables_actives = ones(Bool, n) #Si variables_actives[i]=1, la variable sera traité
    stop2= zeros(Bool , n) #condition d'arret, s'active quand toutes les variables sont traité

    #On crée une liste contenant nos utilités
    util = zeros(Float64, n)

    #Initialisation de la Solution
    SOL = zeros(Bool, n)

    return(desactive_condition, stop1, variables_actives, stop2, util, SOL)
end

 #=================================================================================#

#Détermine l'utilité des éléments basé sur leur nombres d'apparition dans les condition et leur valeur dans les couts
function Utilite(cost, matrix, desactive_condition, n, m , variables_actives, stop1, stop2)

    util = zeros(Float64, n) #réinitialisation du vecteur

    for j=1:n #Pour chaque variable
            if variables_actives[j] == 1 #on verifie si la variable est active
                    for i=1:m #Pour chaque condition
                        if desactive_condition[i]==0 #On verifie si la condition doit être évalué
                            K=matrix[i,j]
                            util[j]=util[j]+K
                        end
                    end

                #On divise le le cout de chqaue variable par son nombre d'appartition dans les conditions
                if util[j]!=false #On évide de divisé par 0...
                    util[j] =  cost[j] / util[j]
                else #Si la variable n'a pas été décompté, on la désactive
                    variables_actives[j] = 0
                end
            end
    end
    return util
end
#============================================================#

function Desactive!(PosCandidat, matrix, desactive_condition, m , variables_actives , n) #On désactive les lignes où est le candidat
    for i=1:m
        if matrix[i,PosCandidat] == 1
            desactive_condition[i] = 1
            for j=1:n
                if matrix[i,j] ==1
                    variables_actives[j] = 0
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

#==========================================#

function choixcandidat(util, alpha) #Permet de construire et de choisir un candidat dans la liste de candidat restreint
    max = maximum(util)
    min = minimum(util)
    Candidat_Restreint = Float64[]
    cpt::Int=1
    for i in 1:length(util)
        if util[i]>= min+(alpha*(max-min))
            push!(Candidat_Restreint,i)
        end
    end
    prob = rand(1:length(Candidat_Restreint))
    return(Candidat_Restreint[prob])
end

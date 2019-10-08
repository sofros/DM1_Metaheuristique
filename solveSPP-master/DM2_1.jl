include("DM1_2.jl")

function GRASP(
    cost, #Une array représentant les couts, de taille n
    matrix, #une matrice de taille m*n representant les contrantes
    n, #nombre de variables
    m, #nombbre de contraintes
    alpha # le alpha que nous allons utiliser
     )

     (desactive_condition, stop1, variables_actives, stop2, util, SOL) = initial(m,n)

    #Création de la solution
    while desactive_condition!=stop1 && variables_actives!=stop2
        #Calcul des utilitées
        util = Utilite(cost, matrix, desactive_condition, n, m , variables_actives, stop1, stop2)
        #Choix du candidat
        PosCandidat::Int64 = choixcandidat(util, alpha)
        #On ajoute le candidat à la solution
        SOL[PosCandidat] = true
        #Desactive! le candidat selectionné et les variables des contraintes où il apparait
        Desactive!(PosCandidat, matrix, desactive_condition, m, variables_actives,n)
    end
    z = calcul_z(SOL,cost,n)
#    println("Valeur Solution GRASP: " , z)
    return(SOL, z, desactive_condition)
end

#===========================================================================#
function initial(m,n)
    #Creating a set of lines that will be avaluated
    desactive_condition= zeros(Bool, m) #si desactive_condition[i]=0 la ligne sera évalué
    stop1= ones(Bool,m) #quand atteint, toutes les conditions ont été évaluées
    #Creation the an array of activated variables
    variables_actives = ones(Bool, n) #si variables_actives[j]=1 la variable xi sera considéré
    stop2= zeros(Bool , n) #quand atteint, toutes les variables ont été traité
    #creating my utility array for my m variables
    util = zeros(Float64, n)
    #initialisation de la Solution
    SOL = zeros(Bool, n)
    return(desactive_condition, stop1, variables_actives, stop2, util, SOL)
end

# =========================================================================== #
#Détermine l'utilitée des élément via leur contribution divisé par leur nombre d'apparition dans les contraintes
function Utilite(cost, matrix, desactive_condition, n, m , variables_actives, stop1, stop2)
    util = zeros(Float64, n) #réinitialisation du vecteur

    for j=1:n # Pour chaque variable
        if variables_actives[j] == 1 #on vérifie si elle est active
                for i=1:m #Pour chaque contrainte
                    if desactive_condition[i]==0 #on vérifie si celle-ci est évaluée
                        K=matrix[i,j]
                        util[j]=util[j]+K #On compte le nombre d'apprationt de xj
                    end #fin if
                end #fin for
            #On calcul la contribution moyenne
            if util[j]!=false #On évide de divisé par 0
                util[j] =  cost[j] / util[j]
            else #Si la variable ne contribue pas, on la désactive
                variables_actives[j] = 0
            end #fin if
        end #fin if
    end #fin for
    return util
end #fin Utilite

# =========================================================================== #
function Desactive!(PosCandidat, matrix, desactive_condition, m , variables_actives , n) #On désactive les conditions où apparaissent le candidat
    for i=1:m #pour chaque contraintes
        if matrix[i,PosCandidat] == 1
            desactive_condition[i] = 1
            for j=1:n #On désactive les variables de la même contrainte
                if matrix[i,j] ==1
                    variables_actives[j] = 0
                end #fin if
            end #fin for des variables
        end #fin if
    end #fin for de contrainte
end #fin Desactive!

#=========================================================================#
function calcul_z(SOL,costs,n)
    z = 0
    for i in 1:n
        z += SOL[i]*costs[i]
    end
    return z
end #fin calcul_z

#==========================================#
function choixcandidat(util, alpha) #On dératemine la liste de candidati restreinte et en choisit un au hasard
    max = maximum(util)
    min = minimum(util)
    liste_candidat_restreint = Float64[]
    cpt::Int = 1
    for i in 1:length(util)
        if util[i] >= trunc(min+(alpha*(max-min))*1000)/1000 #évite les erreur d'apporximation quand alpha = 1, pourrait biaisé le résultat, mais ce n'est arrivé dans aucune instances
            push!(liste_candidat_restreint,i)
        end
    end
    prob = rand(1:length(liste_candidat_restreint)) #tirage aléatoire
    return(liste_candidat_restreint[prob])
end

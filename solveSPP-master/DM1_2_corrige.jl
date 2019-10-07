# =========================================================================== #
# Version mise à jour du DM1 afin de pouvoir faire le DM2
#
# =========================================================================== #

#asked question:
#Mettre en place une heuristique de recherche locale (descente ou plus profonde descente) fondée sur deux voisinages (exemple : type “k-p exchange”).

#taking an array of lenght m
#returning another array of length m
include("DM1_1.jl")

# Notre structure de Solution
mutable struct Solution
    #""""état actuel de notre Solution"""
    x::Array{Bool,1}
    #"""fonction objectif de notre Solution"""
    objectif::Integer

    Solution(x,objectif) = new(x,objectif)
end


"""
    Calcule la fonction objectif d'une Solution
"""
function calculz(x,costs,m)
    objectif = 0
    for i in 1:m
        #checkbounds(x,m)
        objectif += x[i]*costs[i]
    end

    return objectif
end


"""
    fonction qui renvoies "vrai" si la variable j peu être entrée dans la Solution
"""

function select(crts,matrix,m,j)
    selec = true # juste une initialisation
    for l in 1:m
        selec = selec && (( crts[l] * matrix[l,j]) == 0)
    end
    return selec
end

"""
    fonction de kp-exchange avec k=1 et p=1
    fonction lourde : à optimiser
"""
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
                if x_prime.x[j] == 0 && j != i && select(crts,matrix,m,j)# j != i car ça sers à rien de remettre une variable enlevée
                    x_seconde = deepcopy(x_prime)
                    x_seconde.x[j] = 1
                    x_seconde.objectif = calculz(x_seconde.x,couts,n)

                    #on met à jour notre meilleur Solution
                    if x_seconde.objectif > x_best.objectif
                        x_best = deepcopy(x_seconde)
                    end
                end
            end
        end
    end
    #x,objectif= Solution.x
    println(x_best.objectif, "\n")
    return(x_best.x,x_best.objectif)
end


"""
    fonction de kp-exchange avec k=1 et p=1
    fonction lourde : à optimiser
"""
function exchange1_2(solution,n,m,couts,crts,matrix)
    x_best = Solution(solution,calculz(solution,couts,n))
    # notre boucle k
    for i in 1:n
        if  x_best.x[i]  == 1
            x_prime = deepcopy(x_best)
            x_prime.x[i] = 0
            x_prime.objectif = calculz(x_prime.x,couts,n)
            # notre boucle p
            for j = 1:n
                if x_prime.x[j] == 0 && j != i select(crts,matrix,m,j) # j != i car ça sers à rien de remettre une variable enlevée
                    x_seconde = deepcopy(x_prime)
                    x_seconde.x[j] = 1
                    x_seconde.objectif = calculz(x_seconde.x,couts,n)
                    for p in j:n
                        if  x_seconde.x[p] == 0 && p != i && select(crts,matrix,m,p)
                            x_tierce = deepcopy(x_seconde)
                            x_tierce.x[p] = 1
                            x_tierce.objectif = calculz(x_tierce.x,couts,n)

                            if x_tierce.objectif > x_best.objectif
                                x_best = deepcopy(x_tierce)
                            end
                        end
                    end
                    #on met à jour notre meilleur Solution


                end
            end
        end
    end
    #x,objectif= Solution.x
    println(x_best.objectif, "\n")
    return(x_best.x,x_best.objectif)
end



#=
"""
    fonction de kp-exchange avec k=2 et p=1
"""
function exchange2_1(solution,n,m,couts,xbest,crts,matrix)
    x_best = Solution(solution,calculz(solution.x,couts,n))
    #premier k
    for i in 1:n
        if x_best.x[i]  == 1
            x_prime = deepcopy(x_best)
            x_prime.x[i] = 0
            x_prime.objectif = calculz(x_prime.x,couts,n)
            #deuxième k
            for j in 1:n
                if x_seconde[j] == 1
                    x_seconde = deepcopy(x_prime)
                    x_seconde.x[j] = 0
                    x_seconde.objectif = calculz(x_prime.x,couts,n)
                #notre p
                    for p in 1:n
                        if x_tierce[p] && p != i && p != j
                            x_tierce = deepcopy(x_seconde)
                            x_tierce.x[j] = 1
                            x_tierce.objectif = calculz(x_tierce.x,couts,n)

                            #on met a jour notre meilleur Solution
                            if x_tierce.objectif > x_best.objectif
                                x_best = deepcopy(x_tierce)
                            end
                        end
                    end
                end
            end
        end
    end
    #return(Solution.x,Solution.objectif)
end
=#

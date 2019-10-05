# =========================================================================== #
# Version mise à jour du DM1 afin de pouvoir faire le DM2
#
# =========================================================================== #

#asked question:
#Mettre en place une heuristique de recherche locale (descente ou plus profonde descente) fondée sur deux voisinages (exemple : type “k-p exchange”).

#taking an array of lenght m
#returning another array of length m
include("DM1_1.jl")

# Notre structure de solution
mutable struct solution
    """état actuel de notre solution"""
    x::Array(Boolean)
    """fonction objectif de notre solution"""
    z::Integer
end


"""
    Calcule la fonction objectif d'une solution
"""
function calculz(x,costs,m)
    z = 0
    for i in 1:m
        z+= x[i]*costs[i]
    end

    return z
end


"""
    fonction qui renvoies "vrai" si la variable j peu être entrée dans la solution
"""
function select(crts,matrix,m,j)
    selec = true # juste une initialisation
    for l in 1:m
        selec = selec && (( crts[l] * matrix[j,l]) == 0)
    end
    return selec
end

"""
    fonction de kp-exchange avec k=1 et p=1
    fonction lourde : à optimiser
"""
function exchange1_1(soution,n,m,couts,crts,matrix)
    x_best = solution
    # notre boucle k
    for i in 1:n
        if solution.x[i]  == 1
            x_prime = deepcopy(solution)
            x_prime.x[i] = 0
            x_prime.z = calculz(x_prime,couts,m)
            # notre boucle p
            for j = 1:n
                if x_seconde[j] == 0 && j != i # j != i car ça sers à rien de remettre une variable enlevée
                    x_seconde = deepcopy(x_prime)
                    x_seconde.x[j] = 1
                    x_seconde.z = calculz(x_prime,couts,m)

                    #on met à jour notre meilleur Solution
                    if x_seconde.z > x_best.z
                        x_best = deepcopy(x_seconde)
                    end
                end
            end
        end
    end

end



"""
    fonction de kp-exchange avec k=2 et p=1
"""
function exchange2_1(soution,n,m,couts,xbest,crts,matrix)
    x_best = solution
    #premier k
    for i in 1:n
        if solution.x[i]  == 1
            x_prime = deepcopy(solution)
            x_prime.x[i] = 0
            x_prime.z = calculz(x_prime,couts,m)
            #deuxième k
            for j in 1:n
                if x_seconde[j] == 1
                    x_seconde = deepcopy(x_prime)
                    x_seconde.x[j] = 0
                    x_seconde.z = calculz(x_prime,couts,m)
                #notre p
                for p in 1:n
                    if x_tierce[p] && p != i && p != j
                    x_tierce = deepcopy(x_seconde)
                    x_tierce.x[j] = 1
                    x_tierce.z = calculz(xtierce,couts,m)

                    #on met a jour notre meilleur solution
                    if x_tierce.z > x_best.z
                        x_best = deepcopy(x_tierce)
                    end
                end
            end
        end
    end
end

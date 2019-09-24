# =========================================================================== #

# =========================================================================== #

#asked question:
#Mettre en place une heuristique de recherche locale (descente ou plus profonde descente) fondée sur deux voisinages (exemple : type “k-p exchange”).

#taking an array of lenght m
#returning another array of length m


=======
function kpexchange!(
    x::Array(Bool) # Notre solution
    k::Int  # le nombre d'objet à retirer du conteneur
    p::Int  # le nombre d'objet à rajouter dans le conteneur
    m::Int  # taille de x
    zbest::Int  # solution trouvée
    z::Int #solution actuelle
    couts::Array(Int) # tableau des coûts de x
    xbest::Array(Bool) #meilleur solution trouvée
    )

    if k > 0
        for i in m
            if x[i] == 1
                x_prime = copy(x)
                x_prime[i] = 0
                return kp exchange(x_prime,k-1,p,m,zbest,z-gains[i],couts, gain, xbest)
            end
        end

    elseif p > 0
        for j in m
            if x[j] == 0  && z += couts[j] < 1
                x_prime = copy(x)
                x_prime[j] = 1
                z += couts[j]
                if z > zbest
                    xbest = x_prime
                    zbest = z
                end
                return kp exchange(x_prime,k,p-1,m,zbest,z+gains[i],couts, gain, xbest)
            end
        end
    end
end

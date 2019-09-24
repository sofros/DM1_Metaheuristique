# =========================================================================== #

# =========================================================================== #

#asked question:
#Mettre en place une heuristique de recherche locale (descente ou plus profonde descente) fondée sur deux voisinages (exemple : type “k-p exchange”).

#taking an array of lenght m
#returning another array of length m
include("DM1_1.jl")

function calculz(x,costs,m)
    z = 0
    for i in 1:m
        z+= x[i]*costs[i]
    end
    return z
end

function kpexchange!(
    x, # Notre solution
    k::Int,  # le nombre d'objet à retirer du conteneur
    p::Int, # le nombre d'objet à rajouter dans le conteneur
    m::Int,  # taille de x
    zbest::Int,  # solution trouvée
    z::Int, #solution actuelle
    couts, # tableau des coûts de x
    xbest #meilleur solution trouvée
    )

    sol = [xbest,zbest]
    if k > 0
        for i in m
            if x[i] == 1
                x_prime = copy(x)
                x_prime[i] = 0
                sol = kpexchange(x_prime,k-1,p,m,zbest,z-gains[i],couts, gain, xbest)
            end
        end
    elseif p > 0
        for j in m
            if x[j] == 0
                x_prime = copy(x)
                x_prime[j] = 1
                adm = calculz!(x_prime)
                if adm != -1
                    z = adm
                    if z > zbest
                        xbest = x_prime
                        zbest  = z
                    end
                end
                sol = kpexchange(x_prime,k,p-1,m,zbest,z+gains[i],couts, gain, xbest)
            end
        end
    else
        return sol
    end
end

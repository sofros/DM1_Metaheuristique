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
println("===============kp exchange =====================")
    sol = [xbest,zbest]
    if k > 0
        println("========= k =============")
        for i in 1:m
            println("======================")
            println("==> élément ",i," sur ",m)
            println("======================")
            if x[i] == 1
                println("======================")
                println("==> x[i] = 1")
                println("======================")
                x_prime = copy(x)
                println("==> copie effectuée")
                x_prime[i] = 0
                println("==> x[i] passé à 0")
                println("======================")
                println("Appel récursif k")
                sol = kpexchange!(x_prime,k-1,p,m,zbest,z-couts[i],couts, xbest)
            end
        end
    elseif p > 0
        println("========= p =============")
        for j in m
            println("======================")
            println("==> élément ",j," sur ",m)
            println("======================")
            if x[j] == 0
                println("======================")
                println("==> x[j] = 0")
                println("======================")
                x_prime = copy(x)
                println("==> copie effectuée")
                x_prime[j] = 1
                println("==> x[j] passé à 1")
                println("======================")
                println("Appel récursif")
                z = calculz(x_prime,couts,m)
                println("nouvelle solution",z)
                if z != -1
                    println("Z passe en meilleur solution")
                    if z > zbest
                        xbest = x_prime
                        zbest  = z
                    end
                end
                println("Appel récursif p")
                sol = kpexchange!(x_prime,k,p-1,m,zbest,z,couts, xbest)
            end
        end
    else
        println("solution : ", sol)

        return sol
    end
end

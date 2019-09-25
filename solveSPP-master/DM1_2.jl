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
    n::Int,  # taille de x
    m::Int, # nombre de contraintes
    zbest::Int,  # solution trouvée
    z::Int, #solution actuelle
    couts, # tableau des coûts de x
    xbest, #meilleur solution trouvée
    crts, # vecteur des contraintes (on suppose que pout tout i crts[i] =< 1)
    matrix # la matrice des contraintes
    )
println("===============kp exchange =====================")
    sol = (xbest,zbest)
    println("x = ",x)
    if k > 0
        println("========= k =============")
        for i in 1:n
            println("======================")
            println("==> élément ",i," sur ",n)
            println("======================")
            if x[i] == 1
                println("======================")
                println("==> x[",i,"] = 1")
                println("======================")
                x_prime = copy(x)
                println("==> copie effectuée")
                x_prime[i] = 0
                println("==> x[",i,"] passé à 0")
                for crt in 1:m
                    if matrix[i,crt] == 1
                        crts[crt] = 0
                    end
                end
                println("======================")
                println("Appel récursif k")
                sol = kpexchange!(x_prime,k-1,p,n,m,zbest,z-couts[i],couts, xbest,crts)
            end
        end
    elseif p > 0
        println("========= p =============")
        for j in 1:n
            println("======================")
            println("==> élément ",j," sur ",n)
            println("======================")
            if x[j] == 0
                println("======================")
                println("==> x[",j,"] = 0")
                println("======================")
                selec = true # juste une initialisation
                # ici on regarde si on peu rajouter notre variable
                for l in 1:m
                    selec = selec && ( crts[l] + matrix[j,l] >= 1)
                end
                println("crts =", crts, "" )
                if selec
                    x_prime = copy(x)
                    println("==> copie effectuée")
                    x_prime[j] = 1  # on rajoute la variable j à notre solution
                    println("==> x[",j,"] passé à 1")
                    println("======================")
                    println("Appel récursif")
                    z = calculz(x_prime,couts,m)
                    println("nouvelle solution : z = ",z)
                    if z > zbest #on regarde si on a amélioré notre solution
                        println("Z passe en meilleur solution")
                        xbest = x_prime
                        zbest  = z
                    end
                    for crt in 1:m # on met à jour nos contraintes
                        if matrix[j,crt] == 1
                            crts[crt] = 1
                        end
                    end
                end
                println("Appel récursif p")
                sol = kpexchange!(x_prime,k,p-1,n,m,zbest,z,couts, xbest,crts)
            end
        end
    else
        sol = (xbest,zbest)
        println("solution : ", sol)
        return sol
    end
end

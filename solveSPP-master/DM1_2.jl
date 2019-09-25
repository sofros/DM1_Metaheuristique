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

function select(crts,matrix,m,j)
    selec = true # juste une initialisation
    for l in 1:m
        selec = selec && (( crts[l] + matrix[l,j]) <= 1)
        #println(crts[l] + matrix[j,l] )
    end
    return selec
end
function kpexchange!(
    x, # Notre solution
    k::Int,  # le nombre d'objet à retirer du conteneur
    p::Int, # le nombre d'objet à rajouter dans le conteneur
    n::Int,  # taille de x
    m::Int, # nombre de contraintes
    zbest,  # solution trouvée
    z, #solution actuelle
    couts, # tableau des coûts de x
    xbest, #meilleur solution trouvée
    crts, # vecteur des contraintes (on suppose que pout tout i crts[i] =< 1)
    matrix # la matrice des contraintes
    )
#println("===============kp exchange =====================")
    println("x = ",x)
    sol=(xbest,zbest)
    if k > 0

        #println("========= k =============")
        for i in 1:n
            #println("======================")
            #println("==> élément ",i," sur ",n)
            #println("======================")
            if x[i] == 1
                #println("======================")
                #println("==> x[",i,"] = 1")
                #println("======================")
                x_prime = copy(x)
                #println("==> copie effectuée")
                x_prime[i] = 0
                #println("==> x[",i,"] passé à 0")
                for crt in 1:m
                    if matrix[crt,i] == 1
                        crts[crt] = 0
                    end
                    #println("destruction",crts)
                end
                #println("======================")
                #println("Appel récursif k")
            sol = kpexchange!(x_prime,k-1,p,n,m,zbest,z-couts[i],couts, xbest,crts,matrix)
            end
        end
    elseif p > 0
            sol = kpexchange!(x,k,p-1,n,m,zbest,z,couts, xbest,crts,matrix)
        #println("========= p =============")
        for j = 1:n
            #println("======================")
            #println("==> élément ",j," sur ",n)
            #println("======================")
            if sol[1][j] == 0
                #println("======================")
                #println("==> x[",j,"] = 0")
                #println("======================")

                # ici on regarde si on peu rajouter notre variable
                #println("crts =", crts, "" )
                x_prime = copy(sol[1])

                if select(crts,matrix,m,j)

                    #println("==> copie effectuée")
                    x_prime[j] = 1  # on rajoute la variable j à notre solution
                    #println("==> x[",j,"] passé à 1")
                    #println("======================")
                    #println("Appel récursif")
                    z = calculz(x_prime,couts,m)

                    if z > zbest #on regarde si on a amélioré notre solution
                        #println("nouvelle solution : z = ",z)
                        #println("Z passe en meilleur solution")
                        xbest = x_prime
                        zbest  = z

                    end
                    println("P CRTS :", crts)
                    for crt in 1:m # on met à jour nos contraintes
                        if matrix[crt,j] == 1
                            crts[crt] = 1
                        end
                    end
                    #println("nouvelle solution : z = ",zbest)
                end
                #println("Appel récursif p")
            end
        end
    end
    #println("zbest = ", zbest)
    return (xbest,zbest)
end

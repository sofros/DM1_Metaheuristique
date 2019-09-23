# =========================================================================== #

# =========================================================================== #

#asked question:
#Mettre en place une heuristique de recherche locale (descente ou plus profonde descente) fondée sur deux voisinages (exemple : type “k-p exchange”).

#taking an array of lenght m
#returning another array of length m

function kpexchange(
    x::Array(Bool) # Notre solution
    k::Int  # le nombre d'objet à retirer du conteneur
    p::Int  # le nombre d'objet à rajouter dans le conteneur
    m::Int  # taille de x
    )

    i::Int
    j::Int
    ks::Array()
    x_prime =copy(x)   # on copie notre solution
    for n = 1:length(x_prime) - k
        i = 0 # compteur k
        pointeur = n # un pointeur tableau
        for n = i:length(x)
                if x_prime[n] == 1
        end
    end

end

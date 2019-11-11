
t_deb = 100000
t_fin = 1000
alpha = 1/3
palier = 10

function acceptation(solution, delta, t)
 return rand(Float64) <= Base.MathConstants.ℯ ^ (delta/t)
end

function SA(solution,n,m,couts,crts,matrix,mouvement)

    x = Solution(solution,calculz(solution,couts,m))

    bestsol = deepcopy(x)
    t=t_deb

    while t >= t_fin
        for i in 1:palier
            new_sol = deepcopy(x)
            mouvement(new_sol.x,n,m,couts,crts,matrix)
            #println("solitiion " ,i," : ",x.objectif)
            if new_sol.objectif > bestsol.objectif
                bestsol = new_sol
                solution = new_sol
            else
                delta = new_sol.objectif - x.objectif
                if acceptation(new_sol,delta,t)
                    x = new_sol
                end
            end
        end
        t = t*alpha
    end
    return(bestsol,bestsol.objectif)
end


t_deb = 100000
t_fin = 1000
alpha = 1/3
palier = 10

function acceptation(solution, delta, t)
 return rand(Float64) <= Base.MathConstants.ℯ ^ (delta/t)
end

function SA(solution,n,m,couts,crts,matrix,mouvement)
    bestsol = deppcopy(solution)
    t=t_deb

    while t != t_fin
        for i in 1:palier
            new_sol = deepcopy(solution)
            mouvement(new_sol)
            if new_sol.z > bestsol.z
                bestsol = newsol
                solution = newsol
            else
                delta = new_sol.z - solution.z
                if acceptation(newsol,delta,t)
                    solution = newsol
                end
            end
        end
        t = t*alpha
    end
    return(bestsol,bestsol.z)
end

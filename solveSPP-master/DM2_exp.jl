include("DM1_1.jl")
include("DM2_1.jl")
include("DM1_2.jl")
include("loadSPP.jl")
include("setSPP.jl")
include("getfname.jl")

target = "B:/Cours/Nantes/Metaheuristique/DM1_Metaheuristique/solveSPP-master/Data"
fnames = getfname(target)

rep = 10
alpha = 0.8

function UpgradeGRASP(cost, matrix, n, m, alpha)
    (SOL, z, desactive_condition) = GRASP(cost, matrix, n, m, alpha)
    (SOL, z) = exchange1_2(SOL,n,m,cost,desactive_condition,matrix)
    (SOL, z) = exchange1_1(SOL,n,m,cost,desactive_condition,matrix)
    return(SOL, z)
end

function UpgradeGlouton(cost, matrix, n, m, alpha)
    (SOL, z, desactive_condition) = Glouton(cost, matrix, n, m)
    (SOL, z) = exchange1_2(SOL,n,m,cost,desactive_condition,matrix)
    (SOL, z) = exchange1_1(SOL,n,m,cost,desactive_condition,matrix)
    return(SOL, z)
end

function expGRASP(fnames)
    for f in fnames
        println("====================================================================")
        println(f)
        cost, matrix, n, m = loadSPP(f)
        (SOLBest, zBest, desactive_conditionBestBest) = GRASP(cost, matrix, n, m, alpha)
        @time for i in 1:rep
#            (SOL, z, desactive_condition) = GRASP(cost, matrix, n, m, alpha)
#            (SOL, z) = exchange1_2(SOL,n,m,cost,desactive_condition,matrix)
#            (SOL, z) = exchange1_1(SOL,n,m,cost,desactive_condition,matrix)
            (SOL, z) = UpgradeGRASP(cost, matrix, n, m, alpha)
            if z > zBest
                zBest = z
                SOLBest = SOL
            end
        end
        println("Meilleur soluttion pour ", rep , " répétitions, et alpha = ", alpha, " :  ", zBest)
    end
    cd("../")
end

function expGlouton(fnames)
    for f in fnames
        println("====================================================================")
        println(f)
        cost, matrix, n, m = loadSPP(f)

        @time (SOL, z) = UpgradeGlouton(cost, matrix, n, m, alpha)

        println("Solution glouton après amélioration: ", z)
    end
    cd("../")
end


expGRASP(fnames)
#expGlouton(fnames)
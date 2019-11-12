# =========================================================================== #
# Compliant julia 1.x

# Using the following packages
using JuMP, GLPK
using LinearAlgebra

include("loadSPP.jl")
include("setSPP.jl")
include("getfname.jl")
include("experiment.jl")
#include("DM1_1.jl")
#include("DM1_2.jl")
#include("DM2_1.jl")
include("DM2_2.jl")
include("recuit2.jl")
#include("brouillon.jl")

# =========================================================================== #

# Setting the data
#fname = "B:/Cours/Nantes/Metaheuristique/DM1_Metaheuristique/solveSPP-master/Data/didactic.dat"  # path for a standard config on macOS
#cost, matrix, n, m = loadSPP(fname)

# Proceeding to the optimization
#solverSelected = GLPK.Optimizer
#ip, ip_x = setSPP(solverSelected, cost, matrix)
#println("Solving..."); optimize!(ip)

# Displaying the results
#println("z  = ", objective_value(ip))
#sprint("x  = "); println(value.(ip_x))

# =========================================================================== #

# Collecting the names of instances to solve C:Users/Documents/ORO/Metaheuristiques/DM1_Metaheuristique/
#target = "/comptes/E197494S/DM/Metaheuristique/DM1_Metaheuristique-master/solveSPP-master/Data"            # path for a standard config on Linux
#target = "B:/Cours/Nantes/Metaheuristique/DM1_Metaheuristique/solveSPP-master/Data"
target = "C:/Users/Emmanuel/Documents/ORO/Métaheurisques/DM1_Metaheuristique/solveSPP-master/Data"                         # path for personal config on windows10
cd
fnames = getfname(target)

#===================================================#
for f in fnames
    println("====================================================================")
    println(f)
    cost, matrix, n, m = loadSPP(f)
    ite = 15
    alphaset = 0
    temps = 2
    nbAlpha = 5

    #for i in 1:5
    #    @time (SOL,z) =Glouton(cost, matrix, n, m)
    #    @time (SOL,z) =GRASP(cost, matrix, n, m, 0.9)
    #    @time (SOL,z) =Glouton(cost, matrix, n, m)
    #    @time proba = ReactiveGRASP(matrix,cost, n, m, 15, 5, 0, 2)

    #end

    zinit = zeros(Int64, ite) # zero
    zls   = zeros(Int64, ite) # zero
    zbest = zeros(Int64, ite) # zero

    # calcule la valeur du pas pour les divisions

    println("Experimentation ReactiveGRASP-SPP avec :")
    println("  nbIterationGrasp  = ", ite)

    println(" ")
    cpt = 0

    # run non comptabilise (afin de produire le code compile)
    #zinit, zls, zbest = graspSPP(allfinstance[1], 0.5, 1)

    print("  ",f," : ")
    (liste_zavg,liste_zmax,liste_zmin,z_rouge,z_vert,ligne_verte) = ReactiveGRASP(matrix,cost, n, m, ite, nbAlpha, alphaset, temps)
    gr = GRASP(cost,matrix,n,m,0.8)
    println(" ")

    println("Zavg : ")
    #println(liste_zavg)
    println("Zmin : ")
    #println(liste_zmin)
    println("Zmax : ")
    #println(liste_zmax)

        #Pkg.add("PyPlot") # Mandatory before the first use of this package
    println(" ");println("  Graphiques de synthese")

    #plotRunGrasp(f, liste_zmin, zls, liste_zmax)
    plotAnalyseGrasp(f, 1:length(liste_zavg), liste_zavg, liste_zmin, liste_zmax )
    plotRunGrasp(f, z_rouge, z_vert, ligne_verte)
     #On fait une solution de base
    (Sol,z, crts) = GRASP(cost, matrix, n, m, 0.75)
    #test Recuit
    test = SA(Sol,n,m,cost,crts,matrix,exchange1_1)
    println("solution du SA :", test[2])
#    plotAnalyseGrasp(f, x, zmoy[instancenb,:], zmin[instancenb,:], zmax[instancenb,:] )
#    plotCPUt(allfinstance, tmoy)
#=
using Plots
#@userplot PortfolioComposition

     function f(pc::PortfolioComposition)
        weights, returns = pc.args
        weights = cumsum(weights,dims=2)
        seriestype := :shape
        for c=1:size(weights,2)
            sx = vcat(weights[:,c], c==1 ? zeros(length(returns)) : reverse(weights[:,c-1]))
            sy = vcat(returns, reverse(returns))
            Shape(sx, sy)
        end
    end
    using Random
    tickers = ["0.2", "0.4", "0.6", "0.8","1"]
    N = 10
    D = length(tickers)
    weights = rand(N, D)
    weights ./= sum(weights, dims=2)
    returns = sort!((1:N) + D * randn(N))
    portfoliocomposition(weights, returns, labels=permutedims(tickers))=#
end
cd("../")


# ============================================================================ #
#n = 9
#m = 7
#a  = zeros(Float64, n)
#cost = [10, 5, 8, 6, 9, 13, 11, 4, 6]
#matrix = [1 1 1 0 1 0 1 1 0; 0 1 1 0 0 0 0 1 0;0 1 0 0 1 1 0 1 1;0 0 0 1 0 0 0 0 0;1 0 1 0 1 1 0 0 1;0 1 1 0 0 0 1 0 1; 1 0 0 1 1 0 0 1 1]
#a = Glouton(cost, matrix, n, m)
#println("Solution: ",a)

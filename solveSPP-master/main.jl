# =========================================================================== #
# Compliant julia 1.x

# Using the following packages
using JuMP, GLPK
using LinearAlgebra

include("loadSPP.jl")
include("setSPP.jl")
include("getfname.jl")
#include("DM1_1.jl")
#include("DM1_2.jl")
#include("DM2_1.jl")
include("DM2_2.jl")
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
target = "B:/Cours/Nantes/Metaheuristique/DM1_Metaheuristique/solveSPP-master/Data"            # path for a standard config on macOS
cd
fnames = getfname(target)

#===================================================#
for f in fnames
    println("=================")
    println(f)
    cost, matrix, n, m = loadSPP(f)

    #for i in 1:5
    #    @time (SOL,z) =Glouton(cost, matrix, n, m)
    #    @time (SOL,z) =GRASP(cost, matrix, n, m, 0.9)
    #    @time (SOL,z) =Glouton(cost, matrix, n, m)
        @time proba = ReactiveGRASP(matrix,cost, n, m, 15, 5, 1)
    #end
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

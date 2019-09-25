# =========================================================================== #
# Compliant julia 1.x

# Using the following packages
using JuMP, GLPK
using LinearAlgebra

include("loadSPP.jl")
include("setSPP.jl")
include("getfname.jl")
include("DM1_1.jl")

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

# Collecting the names of instances to solve
target = "B:/Cours/Nantes/Metaheuristique/DM1_Metaheuristique/solveSPP-master/Data"            # path for a standard config on macOS
fnames = getfname(target)

#===================================================#
for f in fnames
    println("=================")
    println(f, "\n")
    cost, matrix, n, m = loadSPP(f)
    @time SOL =Glouton(cost, matrix, n, m)
    #println(f,"\n Solution: ",SOL)
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

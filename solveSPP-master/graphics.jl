## Fichier qui créé els graphiques grace aux sorties d'un ReactiveGRASP

#
#Version modifiée à partire de celle de Mr Gandibleux
#

function simulation2(matrix,cost, n, m, ite, coupe, alphaset,f)


    zinit = zeros(Int64, ite) # zero
    zls   = zeros(Int64, ite) # zero
    zbest = zeros(Int64, ite) # zero

    x     = zeros(Int64, nbDivisionRun)
    zmax  = Matrix{Int64}(undef,nbInstances , nbDivisionRun); zmax[:] .= typemin(Int64)  # -Inf entier
    zmoy  = zeros(Float64, nbInstances, nbDivisionRun) # zero
    zmin  = Matrix{Int64}(undef,nbInstances , nbDivisionRun) ; zmin[:] .= typemax(Int64)  # +Inf entier
    tmoy  = zeros(Float64, nbInstances)  # zero

    # calcule la valeur du pas pour les divisions

    println("Experimentation ReactiveGRASP-SPP avec :")
    println("  nbIterationGrasp  = ", ite)

    println(" ")
    cpt = 0

    # run non comptabilise (afin de produire le code compile)
    #zinit, zls, zbest = graspSPP(allfinstance[1], 0.5, 1)

    print("  ",f," : ")
    evol_p,liste_zavg,liste_zmax,liste_zmin,z_rouge,z_vert,ligne_verte = ReactiveGRASP(matrix,cost, n, m, ite, coupe, alphaset)
    gr = GRASP(cost,matrix,n,m,alpha)

    println(" ")

    #Pkg.add("PyPlot") # Mandatory before the first use of this package
    println(" ");println("  Graphiques de synthese")
#    using PyPlot
    instancenb = 1
    plotRunGrasp(f, zinit, zls, zbest)
    plotAnalyseGrasp(f, 1:ite, liste_zavg, liste_zmin, liste_zmax )
    plotCPUt(allfinstance, tmoy)
end

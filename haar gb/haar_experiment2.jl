using ITensors
using Plots
include("header.jl")
include("utils.jl")
# include("plotting.jl")
# include("plotting.jl")
# plotly()
println("starting ITensors Experiment simulation...")

#~~~~~~~~ declaring variables ~~~~~~~~~~
# number of particles (bath and general)
Nbath = 10
N = Nbath + 1

# coupling strength of the gates between the CS and bath
gc = 0.05
# weaken HRM factor
gbs = [0.2*i for i in 0:5]
# number and length of realizations
REP = 40
RANGE = 100




#cse and bse evolve the state over one time period
#cse simulate evlolution of the main qbit in interaction with the bath
#Σ σᶻ₁σᶻᵢdispate the interactions between the qbits in the bath
function centralSpinEvolution(s,g)
    gates = ITensor[]
    for i in 2:N

        hj = op("Z",s[1]) * op("Z",s[i])
        Gj = exp(-1im * g[i-1] * hj)
        push!(gates, Gj)
    end
    return gates
end

function bathSpinEvolution(s,ψ,gb)
    for j in [1;2]
        for i in 1+j:2:N
            s1 = s[i]
            s2 = s[i==N ? 2 : i+1]
            G=itensor(getWeakenHaar(gb),prime(s2),prime(s1),s2,s1)
            ψ = apply(G,ψ)
        end
    end
    ψ
end


# applies one realizaion
function timeDevelopement(s,N,gb,ψ)
    ab = 1/2
    Rs = []
    Θs = []

    gcRandArr = [gc*randn() for n in 1:Nbath]
    centralGates = centralSpinEvolution(s,gcRandArr)

    for i in 1:RANGE

        r,θ = measureR(s,ψ)
        push!(Rs,real(r/ab))
        push!(Θs,θ)

        ψ = apply(centralGates,ψ)
        ψ = bathSpinEvolution(s,ψ,gb)

    end

    Rs,Θs
end

# averaging realizations
function experiment(s,N,gbs,rep)
# first line: [Nbath, Nrealizations, Range, gc, gbs]
    data = Any[]
    push!(data,[N-1 rep RANGE gc size(gbs)[1]])
    for gb ∈ gbs

        for i ∈ 1:rep
            psi0= initStates(s,N)
            psi0 = turnUptoLeft(s,N,psi0)

            r,θ =timeDevelopement(s,N,gb,psi0)
            push!(data,r)
            push!(data,θ)

            println("gb=$gb realization $i out of $rep")
        end
    end
    data
end

let
    s = siteinds("S=1/2",N)
    saveData(experiment(s,N,gbs,REP),"w",Nbath)
end

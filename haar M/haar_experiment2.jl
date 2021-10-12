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

# number of gate layers applied on the bath
Ms = [0 ;1 ;Nbath ;2*Nbath ;3*Nbath ;4*Nbath]
# coupling strength of the gates between the CS and bath
gc = 0.05

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

function bathSpinEvolution(s,ψ)
    for j in [1;2]
        for i in 1+j:2:N
            s1 = s[i]
            s2 = s[i==N ? 2 : i+1]
            G=itensor(createHRM(4),prime(s2),prime(s1),s2,s1)
            ψ = apply(G,ψ)
        end
    end
    ψ
end


# applies one realizaion
function timeDevelopement(s,N,M,ψ)
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
        for j ∈ 1:M
            ψ = bathSpinEvolution(s,ψ)
        end

    end

    Rs,Θs
end

# averaging realizations
function experiment(s,N,Ms,rep)
# first line: [Nbath, Nrealizations, Range, gc, Ms]
    data = Any[]
    push!(data,[N-1 rep RANGE gc size(Ms)[1]])
    for M ∈ Ms

        for i ∈ 1:rep
            psi0= initStates(s,N)
            psi0 = turnUptoLeft(s,N,psi0)

            r,θ =timeDevelopement(s,N,M,psi0)
            push!(data,r)
            push!(data,θ)

            println("M=$M realization $i out of $rep")
        end
    end
    data
end

let
    s = siteinds("S=1/2",N)
    saveData(experiment(s,N,Ms,REP),"w",Nbath)
end

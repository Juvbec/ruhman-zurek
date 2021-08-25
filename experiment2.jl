using ITensors
include("header.jl")
include("utils.jl")
# include("plotting.jl")
# plotly()
println("starting ITensors Experiment simulation...")

# declaring variables
Jxx, Jzz, hx, hz = 0.3, 0.4, 0.2, 0.5
Nbath = 5
N = Nbath + 1
gc = 0.1
# gbs= 0:0.1:0.5
gbs=[0 0.1 0.2 0.3 0.4 0.5]
# gbs = [0.1]
REP = 50
RANGE = 20

# ab=1/2

#cse and bse evolve the state over one time period
#cse simulate evlolution of the main qbit in interaction with the bath
#Σ σᶻ₁σᶻᵢ
#bse simulate the interactions between the qbits in the bath
#Σ Jzzσᶻᵢσᶻᵢ₊₁ + Jₓₓσˣᵢσˣᵢ₊₁ + hzσᶻᵢ + hₓσˣᵢ
#  0.4           0.3           0.5     0.2
function centralSpinEvolution(s,g)
    gates = ITensor[]
    for i in 2:N
        s1 = s[1]
        s2 = s[i]

        hj = op("Z",s1) * op("Z",s2)
        Gj = exp(-1im * g[i-1] * hj)
        push!(gates, Gj)
    end
    return gates
end

function bathSpinEvolution(s,gb)
    gates = ITensor[]
    for i in 2:N
        s1 = s[i]
        s2 = s[i==N ? 2 : i+1]

        # XX and ZZ gates
        hj =  Jzz * op("Z",s1) * op("Z",s2)
            + Jxx * op("X",s1) * op("X",s2)
        Gj = exp(-1im * gb * hj)
        push!(gates, Gj)

        hj = hz * op("Z",s1) + hx * op("X",s1)
        Gj = exp(-1im * gb * hj)
        push!(gates, Gj)

        hj = hz * op("Z",s2) + hx * op("X",s2)
        Gj = exp(-1im * gb * hj)
        push!(gates, Gj)
    end
    return gates
end

function timeDevelopement(s,N,gb,ψ)
    ab = 1/2
    Rs = []
    Θs = []

    gcRandArr = [gc*randn() for n in 1:Nbath]
    centralGates = centralSpinEvolution(s,gcRandArr)
    bathGates = bathSpinEvolution(s,gb)

    for i in 1:RANGE
        r,θ = measureR(s,ψ)
        push!(Rs,real(r/ab))
        push!(Θs,θ)
        ψ = apply(centralGates,ψ)
        ψ = apply(bathGates,ψ)
    end
    Rs,Θs

end
# averaging realizations
function experiment(s,N,gbs,rep)
# first line: [Nbath, Nrealizations, Range, gc, Ngbs]
    data = Any[]
    push!(data,[N-1 rep RANGE gc size(gbs)[2]])
    for gb ∈ gbs
        for i ∈ 1:rep
            psi0= initStates(s,N)
            psi0 = turnUptoLeft(s,N,psi0)

            r,θ =timeDevelopement(s,N,gb,psi0)
            push!(data,r)
            push!(data,θ)

            println("gb= ",gb, ", realization = ",i)
        end
    end
    data
end

let
    s = siteinds("S=1/2",N)
    saveData(experiment(s,N,gbs,REP),"w",Nbath)
end

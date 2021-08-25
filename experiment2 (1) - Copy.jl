using ITensors
include("header.jl")
include("utils.jl")
# include("plotting.jl")
# plotly()
println("starting ITensors Experiment simulation...")

# declaring variables
Jxx, Jzz, hx, hz = 0.3, 0.4, 0.2, 0.5
Nbath = 10
N = Nbath + 1
gc = 0.01
# gbs= 0:0.1:0.5
gbs=[0 0.1 0.2 0.3 0.4 0.5]
REP = 1
RANGE = 20

# ab=1/2

#cse and bse evolve the state over one time period
#cse simulate evlolution of the main qbit in interaction with the bath
#Σ σᶻ₁σᶻᵢ
#bse simulate the interactions between the qbits in the bath
#Σ Jzzσᶻᵢσᶻᵢ₊₁ + Jₓₓσˣᵢσˣᵢ₊₁ + hzσᶻᵢ + hₓσˣᵢ
#  0.4           0.3           0.5     0.2
function centralSpinEvolution(s,ψ,g)

    for i in 2:N
        orthogonalize!(ψ,i)
        ψ=twoSiteGate(s,"Z",g[i-1],1,i)*ψ
    end
    ψ
end

function bathSpinEvolution(s,gb,ψ)
    for i in 2:N
        # ψ=contract(bathSpinHamiltonian(s,gb,N,i),ψ)
        ψ=twoSiteGate(s,"Z",gb*Jzz,i, i==N ? 2 : i+1)*ψ
        ψ=twoSiteGate(s,"X",gb*Jxx,i, i==N ? 2 : i+1)*ψ

        ψ=singleSiteGate(s, "Z", gb*hz, i)*ψ
        ψ=singleSiteGate(s, "Z", gb*hz, i==N ? 2 : i+1)*ψ

        ψ=singleSiteGate(s, "X", gb*hx, i)*ψ
        ψ=singleSiteGate(s, "X", gb*hx, i==N ? 2 : i+1)*ψ
    end
    ψ
end

function timeDevelopement(s,N,gb,ψ)
    ab = 1/2
    Rs = []
    Θs = []
    gcRandArr = [gc*randn() for n in 1:Nbath]
    # gbRandArr = [gb*randn() for n in 1:Nbath]
    for i in 1:RANGE
        r,θ = measureR(s,ψ)
        push!(Rs,real(r/ab))
        push!(Θs,θ)
        println("central spin - bath evolution time:")
        @time ψ = centralSpinEvolution(s,ψ,gcRandArr)
        println("bath evolution time")
        @time ψ = bathSpinEvolution(s,gb,ψ)
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

using ITensors
using Plots
include("utils.jl")
# ITensors.space(::SiteType"S=1/2") = 2

function ITensors.op!(Op::ITensor,
                        ::OpName"PXP",
                        ::SiteType"S=1/2",
                        s::Index)
        Op[s'=>1,s=>2] = 1
end


function initStates(s,N)
  states = ["↑" for n in 1:N]
  productMPS(s,states)
end

function measureR(s,ψ)
  # gate = op("PXP",s[1])
  r = inner(   ψ,      apply(op("S+",s[1]) , ψ)    )
  # r = expect(ψ,"S+";site_range=1:1)[1]
  return abs(r), angle(r)
end


function turnUptoLeft(s,N,psi)
  gates =ITensor[]
  for i in 1:N
      hj = op("Y",s[i])
      Gj = exp(-1im * pi/4 * hj)
      push!(gates,Gj)
  end
  return apply(gates,psi)
  psi
end

function mSvN(s,psi,b)
  orthogonalize!(psi, b)
  # @show linkind(psi,b-1)
  U,S,V = svd(psi[b], (linkind(psi, b-1), siteind(psi,b)))
  SvN = 0.0
  for n=1:dim(S, 1)
    p = S[n,n]^2
    SvN -= p * log(p)
  end
  SvN
end

function createHRM(N::Int)
    x = (rand(N,N) + rand(N,N)*im) / sqrt(2)
    f = qr(x)
    diagR = sign.(real(diag(f.R)))
    diagR[diagR.==0] .= 1
    diagRm = diagm(diagR)
    u = f.Q * diagRm

    return u
end

function getWeakenHaar(gb)
    H = createHRM(4)
    exp(gb*log(H))
end



#
# let
#   plotly()
#   N=6
#   b=3
#   range = 50
#   rep = 50
#   res = zeros(range)
#   s = siteinds("S=1/2", N)
#
#   println("starting simulation...")
#
#   for jm ∈ 1:rep
#     println("realization: $jm")
#     svns = []
#     ψ=initStates(s,N)
#     ψ=turnUptoLeft(s,N,ψ)
#
#     for k in 1:range
#       for j in [1;2]
#         for i in j:2:N
#           s1 = s[i]
#           s2 = s[i==N ? 2 : i+1]
#           G=itensor(createHRM(4),prime(s2),prime(s1),s2,s1)
#           ψ = apply(G,ψ)
#         end
#       end
#       push!(svns,mSvN(s,ψ,b))
#     end
#     res += svns
#   end
#
#   plot(res/(rep*log(2)))
# end

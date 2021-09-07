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

let
  # plotly()
  println("starting simulation...")
  N=2
  # b=3
  range = 1500
  rep = 1
  res = zeros(range)
  s = siteinds("S=1/2", N)

  ψ=initStates(s,N)
  ψ=turnUptoLeft(s,N,ψ)
  s1=siteind(ψ,1)
  s2=siteind(ψ,2)
  G=itensor(createHRM(4),prime(s2),prime(s1),s2,s1)
  ψ = apply(G,ψ)
  @show inner(ψ,ψ)
  # for jm ∈ 1:rep
    # gates = ITensor[]
    #   for j in [1;2]
    #         for i in j:2:N
    #             G=ITensor(createHRM(4),prime(s2),prime(s1),s2,s1)
    #         end
    #     end #end creating gates

        # s1 = s[i]
        # s2 = s[i==N ? 2 : i+1]
        # svns = []
    #
    # for k in 1:range
    #   ψ=apply(gates,ψ)
    #   push!(svns,mSvN(s,ψ,b))
    # end
    # res += svns
  # end
  # display("text/plain","plotting results")
  # plot(res/(rep*log(2)))
end

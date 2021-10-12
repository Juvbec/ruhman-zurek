
# Chaotic hamiltonian SvN
# let
#   plotly()
#   println("starting simulation...")
#   N=8
#   b=4
#   Jxx, Jzz, hx, hz = 0.3, 0.4, 0.2, 0.5
#   g = 0.1 #coupling strength
#   # M = 10 #layers/N
#   range = 1500
#   rep = 1
#   res = zeros(range)
#   s = siteinds("S=1/2", N)
#
#
#   for jm ∈ 1:rep
#     println("$jm. starting realization")
#     gates = ITensor[]
#       # gb=randn()*g
#       gb=g
#       for j in [1;2]
#             for i in j:2:N
#                 s1 = s[i]
#                 s2 = s[i==N ? 2 : i+1]
#
#                 # XX and ZZ gates
#                 hj =  Jzz * op("Z",s1) * op("Z",s2)
#                     + Jxx * op("X",s1) * op("X",s2)
#                 Gj = exp(-1im * gb * hj)
#                 push!(gates, Gj)
#
#                 hj = hz * op("Z",s1) + hx * op("X",s1)
#                 Gj = exp(-1im * gb * hj)
#                 push!(gates, Gj)
#
#                 hj = hz * op("Z",s2) + hx * op("X",s2)
#                 Gj = exp(-1im * gb * hj)
#                 push!(gates, Gj)
#             end
#         end #end creating gates
#         println("$jm. finished creating gates. applying gates")
#         ψ=initStates(s,N)
#         ψ=turnUptoLeft(s,N,ψ)
#         svns = []
#
#     for k in 1:range
#       ψ=apply(gates,ψ)
#       push!(svns,mSvN(s,ψ,b))
#     end
#     res += svns
#   end #end rep
#   display("text/plain","plotting results")
#   plot(res/(rep*log(2)))
# end

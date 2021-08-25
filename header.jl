using ITensors

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
  gate = op("PXP",s[1])
  r = expect(ψ,"PXP";site_range=1:1)
  return abs(r), angle(r)
end


function turnUptoLeft(s,N,psi)
  for i in 1:N
      M = singleSiteGate(s,"Y",pi/4,i)
      psi = M*psi
  end
  psi
end

# MPO tools
# function singleSiteGate(s,op,θ, s1)
#   ampo = AutoMPO()
#
#   ampo += cos(θ),"Id",s1
#   ampo += -1im*sin(θ),op,s1
#
#   MPO(ampo, s)
# end
# function twoSiteGate(s,op,θ,s1,s2)
#   ampo = AutoMPO()
#
#   ampo += cos(θ),"Id",s1,"Id",s2
#   ampo += -1im*sin(θ), op, s1, op, s2
#
#   MPO(ampo, s)
# end
#
# #specific hamiltonians for the simulations
# function bathSpinHamiltonian(s,θ,N,i)
#
#   ampo = AutoMPO()
#   Jxx, Jzz, hx, hz = 0.3, 0.4, 0.2, 0.5
#
#   # ZZ interaction
#   ampo += cos(Jzz*θ),"Id",i,"Id",(i==N ? 2 : (i+1))
#   ampo += -1im*sin(Jzz*θ), "Z", i, "Z", (i==N ? 2 : (i+1))
#
#   # XX interaction
#   # ampo += cos(Jzz*θ),"Id",i,"Id",(i==N ? 2 : (i+1))
#   ampo += -1im*sin(Jzz*θ), "X", i, "X", (i==N ? 2 : (i+1))
#
#   # Z interaction
#   # ampo += cos(hz*θ),"Id",i
#   # ampo += -1im*sin(hz*θ), "Z", i
#
#   # X interaction
#   # ampo += cos(hx*θ),"Id",i
#   # ampo += -1im*sin(hx*θ), "X", i
#
#   MPO(ampo,s)
# end
# function centralSpinHamiltonian(s,gs,N)
#   ampo = AutoMPO()
#   for s in 2:N
#     ampo += cos(gs[s-1]),"Id", 1 , "Id", s
#     ampo += -1im*sin(gs[s-1]),"Z", 1, "Z", s
#   end
#   MPO()
# end





# function measureR(s,ψ)
#
#
#
#   ampo1 = AutoMPO()
#   ampo1 += "ProjUp", 1
#   Pup = MPO(ampo1,s)
#
#   ampo2 = AutoMPO()
#   ampo2 += "ProjDn", 1
#   Pdn = MPO(ampo2,s)
#
#   ampo3 = AutoMPO()
#   ampo3 += "X", 1
#   Sx = MPO(ampo3,s)
#
#   # orthogonalize!(ψ,1)
#
#   ψup = Pup * ψ
#   ψdn = Pdn * ψ
#   r = inner(ψup,Sx,ψdn)
#   return abs(r), angle(r)
# end
#
# let
#   s = siteinds("S=1/2",2)
#   gate = op("PXP",s[1])
#   @show gate
# end

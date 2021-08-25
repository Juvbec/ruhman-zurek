using ITensors

let
  N = 20
  cutoff = 1E-8
  tau = 0.1
  ttotal = 5.0

  # Compute the number of steps to do
  Nsteps = Int(ttotal/tau)

  # Make an array of 'site' indices
  s = siteinds("S=1/2",N)

  # Make gates (1,2),(2,3),(3,4),...
  gates = ITensor[]
  for j=2:N-1
    s1 = s[j]
    s2 = s[j+1]
    hj =       op("Z",s1) * op("Z",s2)
               # op("X",s1) * op("X",s2)
               # op("Z",s1) + op("Z",s2) +
               # op("X",s1) + op("X",s2)

    Gj = exp(-1.0im * tau/2 * hj)
    push!(gates,Gj)
  end
  # Include gates in reverse order too
  # (N,N-1),(N-1,N-2),...
  append!(gates,reverse(gates))

  # Initialize psi to be a product state (alternating up and down)
  psi = productMPS(s, n -> isodd(n) ? "Up" : "Dn")

  c = div(N,2) # center site

  # Compute and print initial <Sz> value on site c
  t = 0.0
  # Sz = expect(psi,"Sz";site_range=c:c)
  # println("$t $Sz")

  # Do the time evolution by applying the gates
  # for Nsteps steps and printing <Sz> on site c
  for step=1:Nsteps
    psi = apply(gates, psi; cutoff=cutoff)
    t += tau
    # Sz = expect(psi,"Sz";site_range=c:c)
    # println("$t $Sz")
  end

  return
end

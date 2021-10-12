using DelimitedFiles
using LinearAlgebra
FILE_FORMAT = "dataN="



function saveData(data, status,N)
    fileStr = FILE_FORMAT*string(N,pad=2)
    cd("data")

    io = open(fileStr, status)
        writedlm(io, data)
    close(io)

    cd(cd(pwd,".."))
end

function readData(N)
    fileStr = FILE_FORMAT*string(N,pad=2)
    cd("data")

    io = open(fileStr, "r")
        res = readdlm(io)
    close(io)

    cd(cd(pwd,".."))

    res
end

function createHRM2(N)
    u = []
    for j ∈ 1:N
        uj = (randn(N) +1im*randn(N))/sqrt(2)
        push!(u,uj/norm(uj))
    end
    hcat([u[i] for i in 1:N]...)
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

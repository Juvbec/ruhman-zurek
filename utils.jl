using DelimitedFiles

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

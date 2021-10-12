using Plots
include("utils.jl")


# creating plotting animation and saving the gif
# saving the gif through plotly didn't work, so i'm using animation
# https://docs.juliaplots.org/latest/recipes/
# http://docs.juliaplots.org/latest/animdistillatioations/
#plotting1 plots the r alone
#plotting2 plots both r and θ on xy plane of bloch sphere
N=10

function plotAverage(data)
    gc = data[1,4]
    plt = plot(
        title=string("Entanglement distillation ; N=$N ; gc=$gc"),
        xguide="Number of Evolutions",
        yguide="r",
        ylims=(0,1)
    )
    for i in 1:Int(data[1,5])
        gb = round(0.2*(i-1),digits=3)

        R=getAverage(data,i)

        display(plot!(
            0:(Int64(data[1,3])-1),
            R,
            label = gb,
        ))
    end

    str = "average N="*string(N,pad=2)
    savefig(str)
end


function getAverage(data,gb)
# first line: [Nbath, Nrealizations, Range, gc, gbs]
    rep = Int64(data[1,2])
    range = Int64(data[1,3])

    R = zeros(range)

    for i in 1 : rep

        R += getArrayFromData(data,gb,i,1,rep)
    end
    R /= rep

    R
end

function getArrayFromData(data,gb,Nrealization,type,rep)
    rowNum = 1 + (gb-1)*rep*2 + (Nrealization-1)*2 + type
    data[rowNum,:]
end
let
    gr()
    data = readData(N)
    plotAverage(data)
    # plotting2(data)
end

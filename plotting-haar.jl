using Plots
include("utils.jl")


# creating plotting animation and saving the gif
# saving the gif through plotly didn't work, so i'm using animation
# https://docs.juliaplots.org/latest/recipes/
# http://docs.juliaplots.org/latest/animdistillatioations/
#plotting1 plots the r alone
#plotting2 plots both r and θ on xy plane of bloch sphere
N=8
spreadNum = 3


@userplot BlochPlot
@recipe function f(cp::BlochPlot)
    X,Y,t = cp.args
    inds = 1:t
    xlims --> (-1.5,1.5)
    ylims --> (-1.5,1.5)
    aspect_ratio --> 1
    # label --> "Entanglement Distillation on Bloch Sphere"
    X[inds] , Y[inds]
end

function plotAverage(data)
    gc = data[1,4]
    plt = plot(
        title=string("Entanglement distillation ; N=$N ; gc=$gc"),
        xguide="Number of Evolutions",
        yguide="r",
        ylims=(0,1)
    )
    for M in 1:Int(data[1,5])

        lb = begin
            if M==1 "0" elseif M==2 "1" else "$(M-2)N" end
        end

        R=getAverage(data,M)

        display(plot!(
            0:(Int64(data[1,3])-1),
            R,
            label = lb,
        ))
    end

    str = "average N="*string(N,pad=2)
    savefig(str)
end


function getAverage(data,M)
# first line: [Nbath, Nrealizations, Range, gc, Ms]
    rep = Int64(data[1,2])
    range = Int64(data[1,3])

    R = zeros(range)

    for i in 1 : rep

        R += getArrayFromData(data,M,i,1,rep)
    end
    R /= rep

    R
end

function getArrayFromData(data,M,Nrealization,type,rep)
    rowNum = 1 + (M-1)*rep*2 + (Nrealization-1)*2 + type
    data[rowNum,:]
end

function plotting2(data)
    range = size(data)[2]
    X,Y = zeros(range,3), zeros(range,3)
    for i in 1:spreadNum
        R = data[2*i,:]
        θ = data[2*i+1,:]

        for j∈1:range
            X[j,i] = R[j]*cos(θ[j])
            Y[j,i] = R[j]*sin(θ[j])
        end
    end
    anim = @animate for t ∈ 1:range-1
        for k in 1:spreadNum
            if k==1 blochplot(X[:,k],Y[:,k],t)
            else blochplot!(X[:,k],Y[:,k],t) end
        end
    end
    gif(anim,"blochsphere.gif", fps=15)
end


let
    gr()
    data = readData(N)
    plotAverage(data)
    # plotting2(data)
end

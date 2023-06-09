#using Plots
#using Images
using PyPlot

# Installing PyPlot: https://github.com/JuliaPy/PyPlot.jl#installation

function read_geography()
    file = open("The_World128x65.dat")
    lines = readlines(file)
    close(file)
    vectors = map(l -> map(s -> parse(Int8, s), split(l, " ")), lines)
    T = mapreduce(permutedims, vcat, reverse(vectors))
    println("read input matrix T of dimensions $(size(T))")
    return T
end

function robinson_projection(T::Matrix{Int8})
    step_size = 2.8125
    X = Matrix{Float64}(undef, 65,128)
    Y = Matrix{Float64}(undef, 65,128)
    for lat=1:65, long=1:128
        𝜑 = deg2rad(-180.0 + (long-1)* step_size)
        𝜃 = deg2rad(-90.0 + (lat-1)* step_size)
        X[lat, long] = (𝜑/pi) * (0.0379*(𝜃^6) - 0.15*(𝜃^4) - 0.367*(𝜃^2) + 2.666)
        Y[lat, long] = (0.96047*𝜃 - 0.00857*sign(𝜃)*(abs(𝜃)^(6.41)))
    end
    return X, Y
end

function plot_geo(X::Matrix, Y::Matrix, T::Matrix{Int8})
    fig, ax0 = subplots(figsize=(13,6), dpi=110) 
    earth = contourf(X,Y,T, 
                levels=[0,1,2,3,5,6],
                colors=[(0.16, 0.38, 0.09),(0.71, 0.77, 0.86),(0.90, 0.90, 0.97),(0.00, 0.03, 0.48), "none"]
            )
    fig.colorbar(earth, ax=ax0, ticks=[1,2,3,5])
    ax0.set_axis_off()
    ax0.set_title("Earth Plot")
    savefig("projection.pdf")
end

# color_lookup = Dict(
#     5 => RGB(0.00, 0.03, 0.48),
#     3 => RGB(0.90, 0.90, 0.97),
#     2 => RGB(0.71, 0.77, 0.86),
#     1 => RGB(0.16, 0.38, 0.09),
# )
# function plot_without_projection(T::Matrix{Int8})
#     G = map(p -> color_lookup[p], T)
#     img = colorview(RGB, G)
#     plot(img)
#     savefig("without_projection.pdf")
# end

T = read_geography()
G = robinson_projection(T)
plot_geo(G[1], G[2], T)

#plot_without_projection(T)
using Contour
using StaticArrays
using BasicInterpolators: BilinearInterpolator

function interpolateBetweenPoints(X::Matrix, Y::Matrix, x, y)
    x_floor = trunc(Int, x)
    y_floor = trunc(Int, y)
    x_range = x_floor:(x_floor+1)
    y_range = y_floor:(y_floor+1)

    if x_floor <= 127 && y_floor <= 64
        IpX = BilinearInterpolator(x_range, y_range, X[x_range, y_range]);
        IpY = BilinearInterpolator(x_range, y_range, Y[x_range, y_range]);
        return IpX(x,y), IpY(x,y)
    else
        return X[x_floor, y_floor], Y[x_floor, y_floor]
    end
end

###### Version 1 ######
# using Plots
function plot_geo(X::Matrix, Y::Matrix, T::Matrix{Int8})
    plot(legend=false, size=(1200,610), axis = nothing, ticks= false, title="Earth Plot")
    for lat=1:64, long=1:127
        rect = Shape(
            [ X[lat, long], X[lat, long+1], X[lat, long+1], X[lat, long] ],
            [ Y[lat, long],  Y[lat, long], Y[lat+1, long], Y[lat+1, long]])

        plot!(rect, fill=color_lookup[T[lat, long]], linewidth=0.2, linecolor=color_lookup[T[lat, long]])
    end
    savefig("projection.pdf")
end

####### Version 2 ######
# using Plots
function plot_geo(X::Matrix, Y::Matrix, T::Matrix{Int8})
    plot(legend=false, size=(1200,610))
    for surface_type in [5,2,3,1]
        # add zeros around to detect the edge
        T_contour = zeros(Int, 67, 130)
        # filter in only the current surface_type
        T_contour[2:66, 2:129] = (i -> Int(i == surface_type)).(T)
        # find contour in T_contour
        lvls = levels(contours(Float64.(1:67),Float64.(1:130),T_contour,1))
        # loop throug isolines
        for line in lines(lvls[1])
            xs, ys = coordinates(line)
            Xs = []
            Ys = []
            color = color_lookup[surface_type]
            for (x,y) in zip(xs,ys)
                x -= 1.0
                x = max(1.0, x)
                y -= 1.0
                y = max(1.0, y)
                x_inter, y_inter = interpolateBetweenPoints(X,Y,x,y)
                push!(Xs, x_inter)
                push!(Ys, y_inter)
            end
            plot!(Shape(Xs, Ys), fill=color_lookup[surface_type], linewidth=0.1)
        end
    end
    savefig("projection.pdf")
end

###### Version 3 ######
# using PyPlots
function plot_geo(X::Matrix, Y::Matrix, T::Matrix{Int8})
    fig, ax0 = subplots(figsize=(13,6), dpi=110) 
    earth = contourf(X,Y,T, levels=[0,1,2,3,5,6] ,colors=[(0.16, 0.38, 0.09),(0.71, 0.77, 0.86),(0.90, 0.90, 0.97),(0.00, 0.03, 0.48), "none"])
    fig.colorbar(earth, ax=ax0, ticks=[1,2,3,5])
    ax0.set_axis_off()
    ax0.set_title("Earth Plot")
    savefig("projection.pdf")
end

###### Version 4 ######
# using PyPlots
function plot_geo(X::Matrix, Y::Matrix, T::Matrix{Int8})
    fig, ax0 = subplots(figsize=(13,6), dpi=110) 
    for surface_type in [5,3,2,1]
        T_contour = (i -> Int(i == surface_type)).(T)
        earth = contourf(X,Y,T_contour, levels=1 ,colors=[(0,0,0,0), color_lookup_py[surface_type]])
    end
    ax0.set_title("Earth Plot")
    ax0.set_axis_off()
    savefig("projection.pdf")
end

###### Version 5 ######
# using PyPlots
function plot_geo(X::Matrix, Y::Matrix, T::Matrix{Int8})
    fig, ax0 = subplots(figsize=(13,6), dpi=110) 
    colormap = ColorMap("test", [0.00 0.90 0.71 0.16; 
                                 0.03 0.90 0.77 0.38;
                                 0.48 0.97 0.86 0.09], 4)
    earth = ax0.pcolormesh(X, Y, T, edgecolors="none", cmap="viridis_r")
    #fig.colorbar(earth, ax=ax0, ticks=[1,2,3,5])
    ax0.set_axis_off()
    ax0.set_title("Earth Plot")
    savefig("projection.pdf")
end

####### Stuff ######

Contour.convert(::Type{Curve2{Float64}}, x::Curve2{Int64}) = Curve2(SVector{2,Float64}[
    SVector{2,Float64}(convert(Float64, t[1]),convert(Float64, t[2])) for t in x.vertices
])
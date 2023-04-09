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

# Contour.convert(::Type{Curve2{Float64}}, x::Curve2{Int64}) = Curve2(SVector{2,Float64}[
#     SVector{2,Float64}(convert(Float64, t[1]),convert(Float64, t[2])) for t in x.vertices
# ])

for cl in levels(contours(1.0:1.0:65.0,1.0:1.0:128.0,T,[1,2,3,5]))
        lvl = level(cl)
        for line in lines(cl)
            xs, ys = coordinates(line)
            Xs = []
            Ys = []
            for (x,y) in zip(xs,ys)
                x_inter, y_inter = interpolateBetweenPoints(X,Y,x,y)
                push!(Xs, x_inter)
                push!(Ys, y_inter)
                # push!(Xs, X[round(Int, x), round(Int, y)])
                # push!(Ys, Y[round(Int, x), round(Int, y)])
            end
            plot!(Xs, Ys, color=:white, linewidth=0.5)
        end
    end
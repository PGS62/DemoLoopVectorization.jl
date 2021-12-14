module DemoLoopVectorization

export comparemethods
using LoopVectorization
using BenchmarkTools

#Entry point when called as an executable
function julia_main()::Cint
    try
        comparemethods()
        return (0)
    catch e
        @error "$e"
        return (1)
    end
end

"""
    threemeans(x::Array{Float64,2})
Returns a tuple of column means of x, column means of positive part of x, 
column means of negative part of x.
"""
function threemeans(x::Array{Float64,2})
    nr, nc = size(x)
    epes = Vector{Float64}(undef, nc)
    enes = Vector{Float64}(undef, nc)
    ees = Vector{Float64}(undef, nc)
    @avx for j = 1:nc
        epe = 0.0
        ene = 0.0
        ee = 0.0
        for i = 1:nr
            ee += x[i, j]
            epe += max(0.0, x[i, j])
            ene += min(0.0, x[i, j])
        end
        epes[j] = epe / nr
        enes[j] = ene / nr
        ees[j] = ee / nr
    end
    epes, enes, ees
end

function threemeans_noavx(x::Array{Float64,2})
    nr, nc = size(x)
    epes = Vector{Float64}(undef, nc)
    enes = Vector{Float64}(undef, nc)
    ees = Vector{Float64}(undef, nc)
    for j = 1:nc
        epe = ene = ee = 0.0
        for i = 1:nr
            ee += x[i, j]
            if x[i, j] > 0
                epe += x[i, j]
            else
                ene += x[i, j]
            end
        end
        epes[j] = epe / nr
        enes[j] = ene / nr
        ees[j] = ee / nr
    end
    epes, enes, ees
end

function threemeans_naive(x::Array{Float64,2})
    epe = vec(mean(max.(x, 0.0), dims = 1))
    ene = vec(mean(min.(x, 0.0), dims = 1))
    ee = vec(mean(x, dims = 1))
    epe, ene, ee
end

#= 13 Dec 2021
julia> comparemethods()
threemeans  475.800 μs (3 allocations: 23.81 KiB)
threemeans_noavx  1.537 ms (3 allocations: 23.81 KiB)
threemeans_naive  6.343 ms (31 allocations: 15.28 MiB)
res1[1] ≈ res2[1] && (res1[2] ≈ res2[2] && res1[3] ≈ res2[3]) = true
res1[1] ≈ res3[1] && (res1[2] ≈ res3[2] && res1[3] ≈ res3[3]) = true
=#
function comparemethods()
    x = rand(1000, 1000)
    print("threemeans")
    res1 = @btime(threemeans($x))
    print("threemeans_noavx")
    res2 = @btime(threemeans_noavx($x))
    print("threemeans_naive")
    res3 = @btime(threemeans_naive($x))

    @show res1[1] ≈ res2[1] && res1[2] ≈ res2[2] && res1[3] ≈ res2[3]
    @show res1[1] ≈ res3[1] && res1[2] ≈ res3[2] && res1[3] ≈ res3[3]
    nothing
end


end #module
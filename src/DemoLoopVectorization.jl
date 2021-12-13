module DemoLoopVectorization

export comparethreemeans

using LoopVectorization
using BenchmarkTools
"""
    threemeans(x::Array{Float64,2})
Returns a tuple of column means of x, column means of positive part of x, column means of negative part of x
"""
function threemeans(x::Array{Float64,2})
    nr, nc = size(x)
    epes = Vector{Float64}(undef,nc)
    enes = Vector{Float64}(undef,nc)
    ees = Vector{Float64}(undef,nc)
    @avx for j = 1:nc
        epe = 0.0
        ene = 0.0
        ee = 0.0
        for i = 1:nr
            ee += x[i,j]
            epe += max(0.0,x[i,j])
            ene += min(0.0,x[i,j])
        end
        epes[j] = epe/nr
        enes[j] = ene/nr
        ees[j] = ee/nr
    end
    epes,enes,ees
end

function threemeans_naive(x::Array{Float64,2})
    function colmeans(x::Array{Float64,2})
        vec(mean(x, dims=1))
    end
    epe = colmeans(max.(x, 0.0))
    ene = colmeans(min.(x, 0.0))
    ee = colmeans(x)
    epe,ene,ee
end

#= 13 Dec 2021
julia> comparethreemeans()
threemeans  654.500 μs (3 allocations: 23.81 KiB)
threemeans_naive  7.031 ms (31 allocations: 15.28 MiB)
res1[1] ≈ res2[1] && (res1[2] ≈ res2[2] && res1[3] ≈ res2[3]) = true
=#
function comparethreemeans()
    x = rand(1000,1000)
    print("threemeans"); res1 = @btime(threemeans($x))
    print("threemeans_naive"); res2 = @btime(threemeans_naive($x))
    @show res1[1] ≈ res2[1] && res1[2] ≈ res2[2] && res1[3] ≈ res2[3]
    nothing
end

#Entry point when called as an executable
function julia_main()::Cint
   try
    comparethreemeans()
    return(0)   
   catch e
    @error "$e"
    return(1)
   end
end




end #module

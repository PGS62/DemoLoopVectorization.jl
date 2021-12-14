# DemoLoopVectorization

[![Build Status](https://github.com/PGS62/DemoLoopVectorization.jl/actions/workflows/CI.yml/badge.svg?branch=main)](https://github.com/PGS62/DemoLoopVectorization.jl/actions/workflows/CI.yml?query=branch%3Amain)

This package is designed to be minimum working example of an issue with Julia packages [LoopVectorization](https://github.com/JuliaSIMD/LoopVectorization.jl) and [PackageCompiler](https://github.com/JuliaLang/PackageCompiler.jl).

It seems that if a package (such as this one) has LoopVectorization as a dependency, and is also compiled to an executable using PackageCompiler, then two problems arise:

 * At run time, the executable emits a warning `Error requiring ForwardDiff from LoopVectorization` (full text below). The warning is not emited when running the code "normally", and contrary to the warning, LoopVectorization _does_ have SIMDDualNumbers as a dependency.
 * There is noticeable latency when running the executable, consistent with some compilation being necessary, even though all code executed should have been properly ahead-of-time compiled via the `precompile_execution_file` argument to `PackageCompiler.create_app`. In my tests (Surface Book 2, Linux under WSL, Julia 1.7) this latency is about 19 seconds.

These problems can be replicated by cloning this package and executing file `src/compile.jl` to create an executable (in folder `DemoLoopVectorization_compiled_for_linux/bin`) and then running that executable. Compilation takes approx half an hour.

## Update 1

For this demo package, in the call to `PackageCompiler.create_app`, setting keyword argument `include_transitive_dependencies=false` seems to fix the first problem and also reduce latency to about 1 second.

## Update 2
Unfortunately setting `include_transitive_dependencies=false` does not fix the problem in the case of a larger (but private) package that uses LoopVectorization and which I wish to compile using PackageCompiler.

Philip Swannell  
14 Dec 2021

```
┌ Warning: Error requiring `ForwardDiff` from `LoopVectorization`
│   exception =
│    LoadError: ArgumentError: Package LoopVectorization does not have SIMDDualNumbers in its dependencies:
│    - If you have LoopVectorization checked out for development and have
│      added SIMDDualNumbers as a dependency but haven't updated your primary
│      environment's manifest file, try `Pkg.resolve()`.
│    - Otherwise you may need to report an issue with LoopVectorization
│    Stacktrace:
│      [1] require(into::Module, mod::Symbol)
│        @ Base ./loading.jl:980
│      [2] include(mod::Module, _path::String)
│        @ Base ./Base.jl:418
│      [3] include(x::String)
│        @ LoopVectorization ~/.julia/packages/LoopVectorization/kVenK/src/LoopVectorization.jl:1
│      [4] top-level scope
│        @ ~/.julia/packages/Requires/7Ncym/src/Requires.jl:40
│      [5] eval
│        @ ./boot.jl:373 [inlined]
│      [6] eval
│        @ ~/.julia/packages/LoopVectorization/kVenK/src/LoopVectorization.jl:1 [inlined]
│      [7] (::LoopVectorization.var"#169#178")()
│        @ LoopVectorization ~/.julia/packages/Requires/7Ncym/src/require.jl:99
│      [8] err(f::Any, listener::Module, modname::String)
│        @ Requires ~/.julia/packages/Requires/7Ncym/src/require.jl:47
│      [9] (::LoopVectorization.var"#168#177")()
│        @ LoopVectorization ~/.julia/packages/Requires/7Ncym/src/require.jl:98
│     [10] withpath(f::Any, path::String)
│        @ Requires ~/.julia/packages/Requires/7Ncym/src/require.jl:37
│     [11] (::LoopVectorization.var"#167#176")()
│        @ LoopVectorization ~/.julia/packages/Requires/7Ncym/src/require.jl:97
│     [12] listenpkg(f::Any, pkg::Base.PkgId)
│        @ Requires ~/.julia/packages/Requires/7Ncym/src/require.jl:20
│     [13] macro expansion
│        @ ~/.julia/packages/Requires/7Ncym/src/require.jl:95 [inlined]
│     [14] __init__()
│        @ LoopVectorization ~/.julia/packages/LoopVectorization/kVenK/src/LoopVectorization.jl:125
│    in expression starting at /home/philip/.julia/packages/LoopVectorization/kVenK/src/simdfunctionals/vmap_grad_forwarddiff.jl:2
└ @ Requires ~/.julia/packages/Requires/7Ncym/src/require.jl:49
```

Version information:
```
julia> versioninfo()
Julia Version 1.7.0
Commit 3bf9d17731 (2021-11-30 12:12 UTC)
Platform Info:
  OS: Linux (x86_64-pc-linux-gnu)
  CPU: Intel(R) Core(TM) i7-8650U CPU @ 1.90GHz
  WORD_SIZE: 64
  LIBM: libopenlibm
  LLVM: libLLVM-12.0.1 (ORCJIT, skylake)
Environment:
  JULIA_NUM_THREADS = 8
  
(DemoLoopVectorization) pkg> st
     Project DemoLoopVectorization v0.1.0
      Status `/mnt/c/Projects/DemoLoopVectorization/Project.toml`
  [6e4b80f9] BenchmarkTools v1.2.2
  [bdcacae8] LoopVectorization v0.12.99

(@v1.7) pkg> st
      Status `~/.julia/environments/v1.7/Project.toml`
  [5fb14364] OhMyREPL v0.5.10
  [9b87118b] PackageCompiler v2.0.4
  [295af30f] Revise v3.2.0
  
```


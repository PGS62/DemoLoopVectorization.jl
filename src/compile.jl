using Pkg
#=Executing this file under windows, create an executable:
DemoLoopVectorization_compiled_for_windows\bin\DemoLoopVectorization.exe
Under linux creates:
DemoLoopVectorization_compiled_for_linux/bin/DemoLoopVectorization

=#
Pkg.activate()#Activate default enviroment
Pkg.add("PackageCompiler")
using PackageCompiler

packagename = "DemoLoopVectorization"

if Sys.iswindows()
    os = "windows"
elseif Sys.islinux()
    os = "linux"
else
    throw("Operating system not supported")
end

srcfolder = @__DIR__
packagefolder = normpath(joinpath(srcfolder, ".."))
startfolder = normpath(joinpath(packagefolder, ".."))
compiled_app = joinpath(startfolder, "$(packagename)_compiled_for_$os")

precompile_execution_file = "$srcfolder/precompile_execution_file.jl"
@info "Start to compile package $packagename into folder '$compiled_app'"
cd(startfolder)
Pkg.activate(packagename)
Pkg.instantiate()
create_app(packagename, compiled_app, force=true, precompile_execution_file=precompile_execution_file)
@info "Finished compiling package $packagename"
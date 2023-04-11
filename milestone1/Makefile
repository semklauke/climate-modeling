run:
	julia --project=. main.jl

runp: Plots.so
	julia  --project=. -JPlots.so main.jl

install:
	julia --project=. --print='using Pkg; Pkg.instantiate()'
	echo "Julia packages installed\n"
	echo "If you are on macos you should:\n"
	echo "\t1. Install XQuartz: https://www.xquartz.org/ \n"
	echo "\t2. Install Homebrew\n"
	echo "\t3. Run 'make install_macos'\n"
	echo "For more infos look at: https://github.com/JuliaPy/PyPlot.jl#os-x"

install_macos:
	brew install python gcc freetype pyqt
	pip install numpy scipy matplotlib

SYSIMAGECOMMAND='\
using Pkg;\
Pkg.add("PackageCompiler");\
using PackageCompiler;\
activate .\
create_sysimage(["Plots", "Images", "PyPlot", "BasicInterpolators", "StaticArrays", "Contour"]; sysimage_path="Plots.so")\
'
Plots.so:
	julia --print=$(SYSIMAGECOMMAND)
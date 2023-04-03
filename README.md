# VTK-m repo for Intel-ANL MS69
This is the README file for VTK-m of Intel-ANL MS69.

About VTK-m: https://gitlab.kitware.com/vtk/vtk-m/-/blob/master/README.md
VTK-m uses Kokkos (https://kokkos.github.io/kokkos-core-wiki/).

## How to clone
```
git clone --recursive https://github.com/czeng-intc/a21_ms69_vtkm.git
```
The `--recursive` option is needed because the `Kokkos` and `VTK-m` source repos are added as submodules.

## How to build
First, make sure your desired SDK is loaded. Then simply run the build scripts as follows for AOT compilation:
```
./build_kokkos.AOT.sh
./build_vtkm.sh
```
To change the build to JIT mode, run
```
./build_kokkos.JIT.sh
./build_vtkm.sh
```
Note the `build_vtkm.sh` does not diffrentiate AOT and JIT explicitly. This is because VTK-m will build on top of existing Kokkos, which aleady determined the mode of compilation (AOT or JIT).

The build scripts (build_*.sh) accept an optional command line argument as the build directory. This is convenient when you want to build the code using a different version of compiler without overwritting the existing results. For example, the build scripts can be invoked as:
```
./build_kokkos.AOT.sh mytest
./build_vtkm.sh mytest
```
In such case, the build will output all intermediate and final binaries to the `mytest` directory. If `mytest` directory does not exist at the moment, the scripts will automatically create it.

When the command line argument is absent, the build scripts will output the files to a predefined default directory named `current`.

After build, the logs are saved in the build output directory (again, `current` if not explicitly supplied).

## Run MS69 related tests
```
./test_vtkm.sh
```
The first set of tests contain 8 unit tests and they should all pass. The second set of test is the Atomic array test which fails for current source.
The screen output will also be saved in a log files available in the build output directory (e.g., `current`).

## Performance collection
Change the `perf_cl` in the `test_vtkm.sh` so the tools such as `onetrace`, `vtune` can be hooked to the tests. The filename of saved test log file will automatically change to reflect the perf tools used.

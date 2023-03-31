#
# |\/|  _. ._   _|  _. _|_  _  ._     |_   _  o |  _  ._ ._  |  _. _|_  _
# |  | (_| | | (_| (_|  |_ (_) | \/   |_) (_) | | (/_ |  |_) | (_|  |_ (/_
#                                /                       |
#
source utils/set_env.bash

setup(){
    source utils/set_test_env.bash #Define ${BATS_TEST_LOG} variable
    load ${ATH_ROOT}/utils/common_functions.bash
    
    load_oneapi
    module load cmake

    # env vars recommended by Intel to alleviate
    # long build times with ocloc
    export IGC_PartitionUnit=1
    export IGC_SubroutineThreshold=50000

    # check if git-lfs is available
    # we need git-lfs for building tests in vtk-m
    if ! command -v git-lfs &> /dev/null
    then
      echo "git-lfs could not be found. Try loading a spack module"
      module load spack git-lfs
      git lfs install
    fi

    export HTTP_PROXY=http://proxy.alcf.anl.gov:3128
    export HTTPS_PROXY=http://proxy.alcf.anl.gov:3128
    export http_proxy=http://proxy.alcf.anl.gov:3128
    export https_proxy=http://proxy.alcf.anl.gov:3128
    git config --global http.proxy http://proxy.alcf.anl.gov:3128

    # Variables for CMake
    export CC=`which icx`
    export CXX=`which icpx`

}

#
# | |  _  _  ._    _  _   _|  _
# |_| _> (/_ |    (_ (_) (_| (/_
#

@test "${_self}_ath_compile" {

    test_init_with_dependency

export WRKDIR=$PWD

#############################################
# Clone Kokkos and VTK-m repositories
#############################################

# clone kokkos repo develop branch
cd $WRKDIR
git clone -b develop https://github.com/kokkos/kokkos.git src/kokkos
cd src/kokkos
git checkout 32868fab5b95d164e975735a6776bdb1b8ac6109

# clone vtk-m v2.0.0
cd $WRKDIR
git clone https://gitlab.kitware.com/vtk/vtk-m.git src/vtk-m
cd src/vtk-m
git checkout bf7983f269f82bab99b2fa4419547da48f617711
git lfs checkout

#############################################
# Configure and build Kokkos SYCL
#############################################

cd $WRKDIR
cmake -S src/kokkos -B build/kokkos \
  -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_CXX_FLAGS="-fPIC -fp-model=precise -Wno-unused-command-line-argument -Wno-deprecated-declarations -fsycl-device-code-split=per_kernel -fsycl-max-parallel-link-jobs=5" \
  -DCMAKE_CXX_FLAGS_DEBUG="-g -O0 -fsycl-link-huge-device-code" \
  -DCMAKE_CXX_STANDARD=17 \
  -DCMAKE_CXX_EXTENSIONS=OFF \
  -DBUILD_SHARED_LIBS=ON \
  -DKokkos_ENABLE_EXAMPLES=OFF \
  -DKokkos_ENABLE_TESTS=OFF \
  -DKokkos_ENABLE_SERIAL=ON \
  -DKokkos_ENABLE_SYCL=ON \
  -DKokkos_ARCH_INTEL_PVC=ON \
  -DCMAKE_INSTALL_PREFIX=$PWD/install/kokkos

cd build/kokkos
make -j8
make install

#############################################
# Configure and build VTK-m
#############################################

cd $WRKDIR
cmake -S src/vtk-m -B build/vtkm \
  -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_CXX_FLAGS="-fPIC -fp-model=precise -Wno-unused-command-line-argument -Wno-deprecated-declarations -fsycl-device-code-split=per_kernel -fsycl-max-parallel-link-jobs=5" \
  -DCMAKE_CXX_FLAGS_DEBUG="-g -O0 -fsycl-link-huge-device-code" \
  -DKokkos_DIR=$PWD/install/kokkos/lib64/cmake/Kokkos \
  -DVTKm_ENABLE_KOKKOS=ON \
  -DVTKm_ENABLE_RENDERING=ON \
  -DVTKm_ENABLE_TESTING=ON \
  -DVTKm_ENABLE_TESTING_LIBRARY=ON \
  -DVTKm_ENABLE_BENCHMARKS=OFF \
  -DCMAKE_INSTALL_PREFIX=$PWD/install/vtkm

cd build/vtkm
make -j8
cd $WRKDIR

}

@test "${_self}_pass_ath_run" {

    test_init_with_dependency

cd build/vtkm
ctest --no-tests=error -R Render -E RenderTestStreamline
cd ../..

}

@test "${_self}_fail_ath_run" {

    test_init_with_dependency

cd build/vtkm
ctest --no-tests=error -R UnitTestKokkosDeviceAdapter --output-on-failure
cd ../..

}



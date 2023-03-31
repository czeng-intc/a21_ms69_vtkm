#!/bin/bash

wdir=${1:-"$PWD/current"}
mkdir -p ${wdir}/{build,install}

source_dir="$PWD/src/vtkm"

build_dir="${wdir}/build/vtkm"
install_dir="${wdir}/install/vtkm"
build_log="${wdir}/build_vtkm.log"

kokkos_dir="${wdir}/install/kokkos/lib64/cmake/Kokkos"

rm -rf ${build_dir}; mkdir -p ${build_dir}

>${build_log}

cmake -S ${source_dir} -B ${build_dir} \
  -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_CXX_FLAGS="-fPIC -fp-model=precise -fno-sycl-early-optimizations -Wno-unused-command-line-argument -Wno-deprecated-declarations -fsycl-device-code-split=per_kernel -fsycl-max-parallel-link-jobs=16" \
  -DCMAKE_CXX_FLAGS_DEBUG="-g -O0 -fsycl-link-huge-device-code" \
  -DKokkos_DIR=${kokkos_dir} \
  -DVTKm_ENABLE_KOKKOS=ON \
  -DVTKm_ENABLE_RENDERING=ON \
  -DVTKm_ENABLE_TESTING=ON \
  -DVTKm_ENABLE_TESTING_LIBRARY=ON \
  -DVTKm_ENABLE_BENCHMARKS=OFF \
  -DCMAKE_INSTALL_PREFIX=${install_dir} |& tee -a ${build_log}

rm -rf ${install_dir}; mkdir -p ${install_dir}
( time make VERBOSE=1 -C ${build_dir} -j16 ) |& tee -a ${build_log}

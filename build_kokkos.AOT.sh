#!/bin/bash

wdir=${1:-"$PWD/current"}
mkdir -p ${wdir}/{build,install}

source_dir="$PWD/src/kokkos"

build_dir="${wdir}/build/kokkos"
install_dir="${wdir}/install/kokkos"
build_log="${wdir}/build_kokkos.log"

rm -rf ${build_dir}; mkdir -p ${build_dir}

>${build_log}

cmake -S ${source_dir} -B ${build_dir} \
  -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_CXX_FLAGS="-fPIC -fp-model=precise -Wno-unused-command-line-argument -Wno-deprecated-declarations -fsycl-device-code-split=per_kernel -fsycl-max-parallel-link-jobs=32" \
  -DCMAKE_CXX_FLAGS_DEBUG="-g -O0 -fsycl-link-huge-device-code" \
  -DCMAKE_CXX_STANDARD=17 \
  -DCMAKE_CXX_EXTENSIONS=OFF \
  -DBUILD_SHARED_LIBS=ON \
  -DKokkos_ENABLE_EXAMPLES=OFF \
  -DKokkos_ENABLE_TESTS=OFF \
  -DKokkos_ENABLE_SERIAL=ON \
  -DKokkos_ENABLE_SYCL=ON \
  -DKokkos_ARCH_INTEL_PVC=ON \
  -DCMAKE_INSTALL_PREFIX=${install_dir} |& tee -a ${build_log}

rm -rf ${install_dir}; mkdir -p ${install_dir}
( time make VERBOSE=1 -C ${build_dir} -j32 install ) |& tee -a ${build_log}

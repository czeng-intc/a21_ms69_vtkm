#!/bin/bash

mkdir -p src/{kokkos,vtkm}

# git clone -b develop https://github.com/kokkos/kokkos.git src/kokkos
# pushd src/kokkos
# git checkout fdb089b34a3c9c087447a52709a436859d117b1f
# popd
git clone -b ms69 https://github.com/czeng-intc/a21_kokkos_src.git src/kokkos

# git clone -b switch_atomics_to_use_desul https://gitlab.kitware.com/bolstadm/vtk-m.git src/vtkm
# pushd src/vtkm
# git checkout d5993147e38447d61d7c0f3a85e8e38536caa40f
# popd
git clone -b ms69 https://github.com/czeng-intc/a21_vtkm_src.git src/vtkm

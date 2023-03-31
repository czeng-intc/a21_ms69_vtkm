#!/bin/bash

wdir=${1:-"$PWD/current"}

perf_cl=""
#perf_cl="$HOME/base/pti-gpu/bin/onetrace -h -d"

perf=`echo ${perf_cl} | awk '{print $1}' | awk -F'/' '{print $NF}'`
if [ -z ${perf} ]; then
  test_log="${wdir}/test_vtkm.log"
else
  test_log="${wdir}/test_vtkm.${perf}.log"
fi

>${test_log}
pushd "${wdir}/build/vtkm"
t0=`date +%s`
( ${perf_cl} ctest --no-tests=error -R Render -E RenderTestStreamline                  ) |& tee -a ${test_log}
( ${perf_cl} ctest --no-tests=error -R UnitTestKokkosDeviceAdapter --output-on-failure ) |& tee -a ${test_log}
t1=`date +%s`
echo "Total wallclock time: $((t1-t0)) s" |& tee -a ${test_log}
popd

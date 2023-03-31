#!/bin/bash

log_file=${1:-"$PWD/current/build_vtkm.log"}

temp_file=temp.$$

grep 'Command being timed:' ${log_file} >${temp_file}.command
grep 'Elapsed (wall clock) time (h:mm:ss or m:ss):' ${log_file} >${temp_file}.time

#grep 'Command being timed:' ${log_file} | awk -F':' '{print $NF}' | sed 's/^ //' >${temp_file}.command
#grep 'Elapsed (wall clock) time (h:mm:ss or m:ss):' ${log_file} | awk '{print $NF}' >${temp_file}.time
#paste -d',' ${temp_file}.time ${temp_file}.command >time_command.csv

#rm -f ${temp_file}.*

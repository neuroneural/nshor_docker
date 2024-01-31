#!/bin/bash

project_dir=/data/users2/jwardell1/nshor_docker/examples/oulu-project
paths_file=${project_dir}/fnc/paths_fnc

num_lines=`wc -l <  $paths_file`
num_total_runs=$(( $num_lines / 3 ))

startix=10
#endix=$(( $num_total_runs - 1 ))
endix=19

sbatch --array=${startix}-${endix} ${project_dir}/fnc/compute_fnc.job

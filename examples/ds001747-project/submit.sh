#!/bin/bash

project_dir=/data/users2/jwardell1/nshor_docker/examples/ds001747-project
paths_file=${project_dir}/ds001747/paths

num_lines=`wc -l <  $paths_file`
num_total_runs=$(( $num_lines / 4 ))

startix=10
endix=$(( $num_total_runs - 1 ))

sbatch --array=${startix}-${endix} ${project_dir}/procruns.job

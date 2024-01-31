#!/bin/bash

project_dir=/data/users2/jwardell1/nshor_docker/examples/oulu-project
paths_file=${project_dir}/OULU/paths

num_lines=`wc -l <  $paths_file`
num_total_runs=$(( $num_lines / 3 ))

startix=10
endix=$(( $num_total_runs - 1 ))

sbatch --array=${startix}-${endix} ${project_dir}/tr100/fsl.job

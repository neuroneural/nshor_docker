#!/bin/bash

project_dir=/data/users2/jwardell1/nshor_docker/examples/devcog-project
paths_file=${project_dir}/DEVCOG/paths

num_lines=`wc -l <  $paths_file`
num_total_runs=$(( $num_lines / 4 ))

startix=166
endix=221


#endix=$(( $num_total_runs - 1 ))

#sbatch --array=0-${runix}%10 ${project_dir}/procruns.job
sbatch --array=${startix}-${endix} ${project_dir}/procruns.job

#!/bin/bash


project_dir=/data/users2/jwardell1/nshor_docker/examples/hcp-project
paths_file=${project_dir}/HCP/paths

num_lines=`wc -l <  $paths_file`
num_total_runs=$(( $num_lines / 9 ))

startix=0
endix=$(( $num_total_runs - 1 ))

#sbatch --array=0-${runix}%9 ${project_dir}/procruns.job
sbatch --array=${startix}-${endix} ${project_dir}/procruns.job

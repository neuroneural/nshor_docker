#!/bin/bash

project_dir=/data/users2/jwardell1/nshor_docker/examples/fbirn-project
paths_file=${project_dir}/FBIRN/paths

num_lines=`wc -l <  $paths_file`
num_total_runs=$(( $num_lines / 4 ))

runix=$(( $num_total_runs - 1 ))


#batch_size=10
#sbatch --array=0-${runix}%${batch_size} ${project_dir}/procruns.job

sbatch --array=0-${runix} ${project_dir}/procruns.job

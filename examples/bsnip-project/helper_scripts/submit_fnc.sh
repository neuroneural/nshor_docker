#!/bin/bash

project_dir=/data/users2/jwardell1/nshor_docker/examples/bsnip-project
paths_file=${project_dir}/helper_scripts/paths_fnc

num_lines=`wc -l <  $paths_file`
num_total_runs=$(( $num_lines / 3 ))

runix=$(( $num_total_runs - 1 ))

sbatch --array=0-${runix} ${project_dir}/helper_scripts/compute_fnc.job

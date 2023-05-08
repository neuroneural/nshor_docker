#!/bin/bash

project_dir=/data/users2/jwardell1/nshor_docker/ds004078-project
paths_file=${project_dir}/ds004078/paths

num_lines=`wc -l <  $paths_file`
num_total_runs=$(( $num_lines / 3  ))

sbatch --array=0-$num_total_runs ${project_dir}/procruns.job 

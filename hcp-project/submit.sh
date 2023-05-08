#!/bin/bash

project_dir=/data/users2/jwardell1/nshor_docker/hcp-project
paths_file=${project_dir}/HCP/paths

num_lines=`wc -l <  $paths_file`
num_total_runs=$(( $num_lines / 8  ))

sbatch --array=0-$num_total_runs ${project_dir}/procruns.job 

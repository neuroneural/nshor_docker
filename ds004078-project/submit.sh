#!/bin/bash

paths_file=/data/users2/jwardell1/nshor_docker/ds004078-project/ds004078/paths

num_lines=`wc -l <  $paths_file`
num_total_runs=$(( $num_lines / 3  ))

sbatch --array=0-$num_total_runs procruns.job 

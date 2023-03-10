#!/bin/bash

paths_file=/data/users2/jwardell1/nshor_docker/fbirn-project/FBIRN/paths
num_lines=`wc -l $path_file`
num_total_runs=$(( $num_lines / 3  ))

sbatch procruns.job --array=0-$num_total_runs

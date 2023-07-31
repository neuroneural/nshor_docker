#!/bin/bash


project_dir=/data/users2/jwardell1/nshor_docker/examples/hcp-project
paths_file=${project_dir}/HCP/paths

num_lines=`wc -l <  $paths_file`
num_total_runs=$(( $num_lines / 10 ))
runix=$(( $num_total_runs - 1 ))

<<<<<<< HEAD
sbatch --array=0-${runix}%10 ${project_dir}/procruns.job
=======
sbatch --array=0-${runix}%20 ${project_dir}/procruns.job
>>>>>>> a2b3487cf79bf48ce8aaffb9d73f49e198e0041f

#!/bin/bash

project_dir=/data/users2/jwardell1/nshor_docker/examples/bsnip-project
subs_file=${project_dir}/BSNIP/Boston/subjects.txt

num_total_runs=`cat $subs_file | wc -l`

sbatch --array=0-$num_total_runs ${project_dir}/BSNIP/Boston/group_mean_masks/generate_group_mask.job

#!/bin/bash

echo "in submit_group_mean_masks.sh"

project_dir=/data/users2/jwardell1/nshor_docker/examples/hcp-project
echo "project_dir is $project_dir"

subs_file=${project_dir}/HCP/subjects.txt
echo "subs_file is $subs_file"

num_total_runs=`cat $subs_file | wc -l`
echo "num_total_runs is $num_total_runs"

echo `ls -l ${project_dir}/HCP/group_mean_masks/generate_group_mask.job`
runix="$(($num_total_runs - 1))"
echo "runix is $runix"
sbatch --array=0-$runix%5 ${project_dir}/HCP/group_mean_masks/generate_group_mask.job


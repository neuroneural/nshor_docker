#!/bin/bash


cp /data/users2/jwardell1/nshor_docker/examples/ds004078-project/ds004078/mkpths.sh /data/users2/jwardell1/nshor_docker/examples/ds004078-project/
cp /data/users2/jwardell1/nshor_docker/examples/ds004078-project/ds004078/subjects.txt /data/users2/jwardell1/nshor_docker/examples/ds004078-project/
rm -rf /data/users2/jwardell1/nshor_docker/examples/ds004078-project/ds004078
mkdir /data/users2/jwardell1/nshor_docker/examples/ds004078-project/ds004078
mv /data/users2/jwardell1/nshor_docker/examples/ds004078-project/subjects.txt /data/users2/jwardell1/nshor_docker/examples/ds004078-project/ds004078/subjects.txt
mv /data/users2/jwardell1/nshor_docker/examples/ds004078-project/mkpths.sh /data/users2/jwardell1/nshor_docker/examples/ds004078-project/ds004078/mkpths.sh
bash /data/users2/jwardell1/nshor_docker/examples/ds004078-project/ds004078/mkpths.sh

project_dir=/data/users2/jwardell1/nshor_docker/examples/ds004078-project
paths_file=${project_dir}/ds004078/paths

num_lines=`wc -l <  $paths_file`
num_total_runs=$(( $num_lines / 3  ))

sbatch --array=0-$num_total_runs ${project_dir}/procruns.job 

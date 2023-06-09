#!/bin/bash


cp /data/users2/jwardell1/nshor_docker/examples/hcp-project/HCP/mkpths.sh /data/users2/jwardell1/nshor_docker/examples/hcp-project/
cp /data/users2/jwardell1/nshor_docker/examples/hcp-project/HCP/subjects.txt /data/users2/jwardell1/nshor_docker/examples/hcp-project/
rm -rf /data/users2/jwardell1/nshor_docker/examples/hcp-project/HCP
mkdir /data/users2/jwardell1/nshor_docker/examples/hcp-project/HCP
mv /data/users2/jwardell1/nshor_docker/examples/hcp-project/subjects.txt /data/users2/jwardell1/nshor_docker/examples/hcp-project/HCP/subjects.txt
mv /data/users2/jwardell1/nshor_docker/examples/hcp-project/mkpths.sh /data/users2/jwardell1/nshor_docker/examples/hcp-project/HCP/mkpths.sh
bash /data/users2/jwardell1/nshor_docker/examples/hcp-project/HCP/mkpths.sh


project_dir=/data/users2/jwardell1/nshor_docker/examples/hcp-project
paths_file=${project_dir}/HCP/paths

num_lines=`wc -l <  $paths_file`
num_total_runs=$(( $num_lines / 3  ))

sbatch --array=0-$num_total_runs ${project_dir}/procruns.job 

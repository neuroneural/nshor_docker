#!/bin/bash


cp /data/users2/jwardell1/nshor_docker/examples/hcpnm-project/HCP/mkpths.sh /data/users2/jwardell1/nshor_docker/examples/hcpnm-project/
cp /data/users2/jwardell1/nshor_docker/examples/hcpnm-project/HCP/subjects.txt /data/users2/jwardell1/nshor_docker/examples/hcpnm-project/
rm -rf /data/users2/jwardell1/nshor_docker/examples/hcpnm-project/HCP
mkdir /data/users2/jwardell1/nshor_docker/examples/hcpnm-project/HCP
mv /data/users2/jwardell1/nshor_docker/examples/hcpnm-project/subjects.txt /data/users2/jwardell1/nshor_docker/examples/hcpnm-project/HCP/subjects.txt
mv /data/users2/jwardell1/nshor_docker/examples/hcpnm-project/mkpths.sh /data/users2/jwardell1/nshor_docker/examples/hcpnm-project/HCP/mkpths.sh
bash /data/users2/jwardell1/nshor_docker/examples/hcpnm-project/HCP/mkpths.sh


project_dir=/data/users2/jwardell1/nshor_docker/examples/hcpnm-project
paths_file=${project_dir}/HCP/paths

num_lines=`wc -l <  $paths_file`
num_total_runs=$(( $num_lines / 3  ))

sbatch --array=0-$num_total_runs ${project_dir}/procruns.job 

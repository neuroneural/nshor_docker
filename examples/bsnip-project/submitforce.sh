#!/bin/bash


cp /data/users2/jwardell1/nshor_docker/examples/bsnip-project/BSNIP/Boston/mkpths.sh /data/users2/jwardell1/nshor_docker/examples/bsnip-project/
cp /data/users2/jwardell1/nshor_docker/examples/bsnip-project/BSNIP/Boston/subjects.txt /data/users2/jwardell1/nshor_docker/examples/bsnip-project/
rm -rf /data/users2/jwardell1/nshor_docker/examples/bsnip-project/BSNIP
mkdir /data/users2/jwardell1/nshor_docker/examples/bsnip-project/BSNIP
mkdir /data/users2/jwardell1/nshor_docker/examples/bsnip-project/BSNIP/Boston
mv /data/users2/jwardell1/nshor_docker/examples/bsnip-project/subjects.txt /data/users2/jwardell1/nshor_docker/examples/bsnip-project/BSNIP/Boston/subjects.txt
mv /data/users2/jwardell1/nshor_docker/examples/bsnip-project/mkpths.sh /data/users2/jwardell1/nshor_docker/examples/bsnip-project/BSNIP/Boston/mkpths.sh
bash /data/users2/jwardell1/nshor_docker/examples/bsnip-project/BSNIP/Boston/mkpths.sh



project_dir=/data/users2/jwardell1/nshor_docker/examples/bsnip-project
paths_file=${project_dir}/BSNIP/Boston/paths

num_lines=`wc -l <  $paths_file`
num_total_runs=$(( $num_lines / 3  ))

sbatch --array=0-$num_total_runs ${project_dir}/procruns.job 

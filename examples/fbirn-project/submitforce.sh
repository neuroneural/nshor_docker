#!/bin/bash

cp /data/users2/jwardell1/nshor_docker/examples/fbirn-project/FBIRN/mkpths.sh /data/users2/jwardell1/nshor_docker/examples/fbirn-project/
cp /data/users2/jwardell1/nshor_docker/examples/fbirn-project/FBIRN/subjects.txt /data/users2/jwardell1/nshor_docker/examples/fbirn-project/
rm -rf /data/users2/jwardell1/nshor_docker/examples/fbirn-project/FBIRN
mkdir /data/users2/jwardell1/nshor_docker/examples/fbirn-project/FBIRN
mv /data/users2/jwardell1/nshor_docker/examples/fbirn-project/subjects.txt /data/users2/jwardell1/nshor_docker/examples/fbirn-project/FBIRN/subjects.txt
mv /data/users2/jwardell1/nshor_docker/examples/fbirn-project/mkpths.sh /data/users2/jwardell1/nshor_docker/examples/fbirn-project/FBIRN/mkpths.sh
bash /data/users2/jwardell1/nshor_docker/examples/fbirn-project/FBIRN/mkpths.sh

project_dir=/data/users2/jwardell1/nshor_docker/examples/fbirn-project
paths_file=${project_dir}/FBIRN/paths

num_lines=`wc -l <  $paths_file`
num_total_runs=$(( $num_lines / 3  ))

sbatch --array=0-$num_total_runs ${project_dir}/procruns.job 

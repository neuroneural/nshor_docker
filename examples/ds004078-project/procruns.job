#!/bin/bash
#SBATCH -n 4
#SBATCH -c 4
#SBATCH --mem=120g
#SBATCH -p qTRD
#SBATCH --time=20:00:00
#SBATCH -J PRP4078
#SBATCH -e /data/users2/jwardell1/nshor_docker/examples/ds004078-project/jobs/error%A_%a.err
#SBATCH -o /data/users2/jwardell1/nshor_docker/examples/ds004078-project/jobs/out%A_%a.out
#SBATCH -A psy53c17
#SBATCH --mail-type=ALL
#SBATCH --mail-user=jwardell1@student.gsu.edu
#SBATCH --oversubscribe

sleep 5s

module load singularity/3.10.2

SUB_PATHS_FILE=/data/users2/jwardell1/nshor_docker/examples/ds004078-project/ds004078/paths

SIF_FILE=/data/users2/jwardell1/nshor_docker/dkrimg.sif
RUN_BIND_POINT=/data/users2/jwardell1/nshor_docker
SCRIPT_NAME=pd_dockerParallelized.sh

IFS=$'\n'
paths_array=($(cat ${SUB_PATHS_FILE}))
func_ix=$(( 4*$SLURM_ARRAY_TASK_ID ))
anat_ix=$(( 4*$SLURM_ARRAY_TASK_ID + 1 ))
json_ix=$(( 4*$SLURM_ARRAY_TASK_ID + 2 ))
out_ix=$(( 4*$SLURM_ARRAY_TASK_ID + 3 ))

func_filepath=${paths_array[${func_ix}]}
anat_filepath=${paths_array[${anat_ix}]}
json_filepath=${paths_array[${json_ix}]}

out_bind=${paths_array[${out_ix}]}
func_bind=`dirname $func_filepath`
anat_bind=`dirname $anat_filepath`

func_file=`basename $func_filepath`
anat_file=`basename $anat_filepath`
json_file=`basename $json_filepath`

singularity exec --writable-tmpfs --bind $RUN_BIND_POINT:/run,$func_bind:/func,$anat_bind:/anat,$out_bind:/out $SIF_FILE /run/${SCRIPT_NAME} -f $func_file -a $anat_file -j $json_file -o $out_bind &


wait

sleep 10s

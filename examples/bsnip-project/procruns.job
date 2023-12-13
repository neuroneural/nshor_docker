#!/bin/bash
#SBATCH -n 1
#SBATCH -c 4
#SBATCH --mem=64g
#SBATCH -p qTRD
#SBATCH --time=20:00:00
#SBATCH -J PRPbsnip
#SBATCH -e /data/users2/jwardell1/nshor_docker/examples/bsnip-project/jobs/error%A_%a.err
#SBATCH -o /data/users2/jwardell1/nshor_docker/examples/bsnip-project/jobs/out%A_%a.out
#SBATCH -A psy53c17
#SBATCH --mail-type=ALL
#SBATCH --mail-user=jwardell1@student.gsu.edu
#SBATCH --oversubscribe

sleep 5s

module load singularity/3.10.2

SUB_PATHS_FILE=/data/users2/jwardell1/nshor_docker/examples/bsnip-project/BSNIP/Boston/paths

SIF_FILE=/data/users2/jwardell1/nshor_docker/fmriproc.sif
#RUN_BIND_POINT=/data/users2/jwardell1/nshor_docker
#SCRIPT_NAME=pd_dockerParallelized.sh

IFS=$'\n'
paths_array=($(cat ${SUB_PATHS_FILE}))

func_ix=$(( 3*$SLURM_ARRAY_TASK_ID ))
anat_ix=$(( 3*$SLURM_ARRAY_TASK_ID + 1 ))
out_ix=$(( 3*$SLURM_ARRAY_TASK_ID + 2 ))

func_filepath=${paths_array[${func_ix}]}
anat_filepath=${paths_array[${anat_ix}]}

out_bind=${paths_array[${out_ix}]}
func_bind=`dirname $func_filepath`
anat_bind=`dirname $anat_filepath`

func_file=`basename $func_filepath`
anat_file=`basename $anat_filepath`

#singularity exec --writable-tmpfs --bind $RUN_BIND_POINT:/run,$func_bind:/func,$anat_bind:/anat,$mask_bind:/mask,$out_bind:/out $SIF_FILE /run/${SCRIPT_NAME} -f $func_file -a $anat_file -m $mask_file -o $out_bind &
singularity exec --writable-tmpfs --bind $func_bind:/func,$anat_bind:/anat,$out_bind:/out $SIF_FILE /main.sh -f $func_file -a $anat_file -o $out_bind &


wait

sleep 10s

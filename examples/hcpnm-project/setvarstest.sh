#!/bin/bash

module load singularity/3.10.2

SUB_PATHS_FILE=/data/users2/jwardell1/nshor_docker/examples/hcpnm-project/HCP/paths

SIF_FILE=/data/users2/jwardell1/nshor_docker/dkrimg.sif
RUN_BIND_POINT=/data/users2/jwardell1/nshor_docker
SCRIPT_NAME=pd_dockerParallelized.sh

SLURM_ARRAY_TASK_ID=0

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

#!/bin/bash

module load singularity/3.10.2

export SUB_PATHS_FILE=/data/users2/jwardell1/nshor_docker/examples/devcog-project/DEVCOG/paths

export SIF_FILE=/data/users2/jwardell1/nshor_docker/fmriproc.sif
#export RUN_BIND_POINT=/data/users2/jwardell1/nshor_docker

if [ -z $1 ]; then
	export SLURM_ARRAY_TASK_ID=0
else
	export SLURM_ARRAY_TASK_ID=$1
fi

echo "SLURM_ARRAY_TASK_ID- $SLURM_ARRAY_TASK_ID"
hostname=`hostname`
echo "hostname- $hostname"

export IFS=$'\n'
export paths_array=($(cat ${SUB_PATHS_FILE}))
export func_ix=$(( 4*$SLURM_ARRAY_TASK_ID ))
export anat_ix=$(( 4*$SLURM_ARRAY_TASK_ID + 1 ))
export json_ix=$(( 4*$SLURM_ARRAY_TASK_ID + 2 ))
export out_ix=$(( 4*$SLURM_ARRAY_TASK_ID + 3 ))

export func_filepath=${paths_array[${func_ix}]}
export anat_filepath=${paths_array[${anat_ix}]}
export json_filepath=${paths_array[${json_ix}]}

export out_bind=${paths_array[${out_ix}]}
export func_bind=`dirname $func_filepath`
export anat_bind=`dirname $anat_filepath`

export func_file=`basename $func_filepath`
export anat_file=`basename $anat_filepath`
export json_file=`basename $json_filepath`

echo "func_ix = $func_ix"
echo "func_filepath = $func_filepath"
echo "anat_filepath = $anat_filepath"
echo "json_filepath = $json_filepath"
echo "out_bind = $out_bind"


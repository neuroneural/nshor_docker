#!/bin/bash

if [ -z $1 ]; then
	SLURM_ARRAY_TASK_ID=0
else
	SLURM_ARRAY_TASK_ID=$1
fi

module load singularity/3.10.2

export SUB_PATHS_FILE=/data/users2/jwardell1/nshor_docker/examples/ds001747-project/ds001747/paths

export SIF_FILE=/data/users2/jwardell1/nshor_docker/fmriproc.sif

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

echo "func_file: $func_file"
echo "anat_file: $anat_file"
echo "json_file: $json_file"
echo "out_bind: $out_bind"

#singularity exec --writable-tmpfs --bind $RUN_BIND_POINT:/run,$func_bind:/func,$anat_bind:/anat,$out_bind:/out $SIF_FILE /main.sh -f $func_file -a $anat_file -j $json_file -o $out_bind &


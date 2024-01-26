#!/bin/bash
module load singularity/3.10.2

export SUB_PATHS_FILE=/data/users2/jwardell1/nshor_docker/examples/oulu-project/OULU/paths

export SIF_FILE=/data/users2/jwardell1/nshor_docker/fmriproc.sif
#export RUN_BIND_POINT=/data/users2/jwardell1/nshor_docker

if [ -z $1 ]; then
	export SLURM_ARRAY_TASK_ID=0
else
	export SLURM_ARRAY_TASK_ID=$1
fi

export IFS=$'\n'
export paths_array=($(cat ${SUB_PATHS_FILE}))
export func_ix=$(( 3*$SLURM_ARRAY_TASK_ID ))
export anat_ix=$(( 3*$SLURM_ARRAY_TASK_ID + 1 ))
export out_ix=$(( 3*$SLURM_ARRAY_TASK_ID + 2 ))

export func_filepath=${paths_array[${func_ix}]}
export anat_filepath=${paths_array[${anat_ix}]}

export out_bind=${paths_array[${out_ix}]}
export func_bind=`dirname $func_filepath`
export anat_bind=`dirname $anat_filepath`

export func_file=`basename $func_filepath`
export anat_file=`basename $anat_filepath`

#singularity exec --writable-tmpfs --bind $func_bind:/func,$anat_bind:/anat,$out_bind:/out $SIF_FILE /main.sh -f $func_file -a $anat_file -o $out_bind &
#singularity exec --writable-tmpfs --bind $func_bind:/func,$anat_bind:/anat,$out_bind:/out,${RUN_BIND_POINT}:/run $SIF_FILE /run/pd_dockerParallelized.sh -f $func_file -a $anat_file -o $out_bind &


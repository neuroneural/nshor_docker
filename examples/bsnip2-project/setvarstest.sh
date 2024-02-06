#!/bin/bash
module load singularity/3.10.2

export SUB_PATHS_FILE=/data/users2/jwardell1/nshor_docker/examples/bsnip2-project/BSNIP2/paths

export SIF_FILE=/data/users2/jwardell1/nshor_docker/fmriproc.sif

export SLURM_ARRAY_TASK_ID=0

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

#!/bin/bash
module load singularity/3.10.2

export SUB_PATHS_FILE=/data/users2/jwardell1/nshor_docker/hcp-project/HCP/paths

export SIF_FILE=/data/users2/jwardell1/nshor_docker/dkrimg.sif
export RUN_BIND_POINT=/data/users2/jwardell1/nshor_docker
export SCRIPT_NAME=pd_dockerParallelized.sh

export SLURM_ARRAY_TASK_ID=1


export IFS=$'\n'
export paths_array=($(cat ${SUB_PATHS_FILE}))
export func_ix=$(( 8*$SLURM_ARRAY_TASK_ID ))
export anat_ix=$(( 8*$SLURM_ARRAY_TASK_ID + 1 ))
export spinlr_ix=$(( 8*$SLURM_ARRAY_TASK_ID + 2 ))
export spinrl_ix=$(( 8*$SLURM_ARRAY_TASK_ID + 3 ))
export biasch_ix=$(( 8*$SLURM_ARRAY_TASK_ID + 4 ))
export biasbc_ix=$(( 8*$SLURM_ARRAY_TASK_ID + 5 ))
export sbref_ix=$(( 8*$SLURM_ARRAY_TASK_ID + 6 ))
export out_ix=$(( 8*$SLURM_ARRAY_TASK_ID + 7 ))

export func_filepath=${paths_array[${func_ix}]}
export anat_filepath=${paths_array[${anat_ix}]}
export spinlr_filepath=${paths_array[${spinlr_ix}]}
export spinrl_filepath=${paths_array[${spinrl_ix}]}
export biasch_filepath=${paths_array[${biasch_ix}]}
export biasbc_filepath=${paths_array[${biasbc_ix}]}
export sbref_filepath=${paths_array[${sbref_ix}]}
 
export out_bind=${paths_array[${out_ix}]}
export func_bind=`dirname $func_filepath`
export anat_bind=`dirname $anat_filepath`

export func_file=`basename $func_filepath`
export anat_file=`basename $anat_filepath`
export spinlr_file=`basename $spinlr_filepath`
export spinrl_file=`basename $spinrl_filepath`
export biasch_file=`basename $biasch_filepath`
export biasbc_file=`basename $biasbc_filepath`
export sbref_file=`basename $sbref_filepath`

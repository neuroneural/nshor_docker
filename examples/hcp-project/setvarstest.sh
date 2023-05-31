#!/bin/bash

module load singularity


SLURM_ARRAY_TASK_ID=1

SUB_PATHS_FILE=/data/users2/jwardell1/nshor_docker/examples/hcp-project/HCP/paths

SIF_FILE=/data/users2/jwardell1/nshor_docker/dkrimg.sif
RUN_BIND_POINT=/data/users2/jwardell1/nshor_docker
SCRIPT_NAME=pd_dockerParallelized.sh

IFS=$'\n'
paths_array=($(cat ${SUB_PATHS_FILE}))
func_ix=$(( 9*$SLURM_ARRAY_TASK_ID ))
anat_ix=$(( 9*$SLURM_ARRAY_TASK_ID + 1 ))
spinlr_ix=$(( 9*$SLURM_ARRAY_TASK_ID + 2 ))
spinrl_ix=$(( 9*$SLURM_ARRAY_TASK_ID + 3 ))
biasch_ix=$(( 9*$SLURM_ARRAY_TASK_ID + 4 ))
biasbc_ix=$(( 9*$SLURM_ARRAY_TASK_ID + 5 ))
sbref_ix=$(( 9*$SLURM_ARRAY_TASK_ID + 6 ))
params_ix=$(( 9*$SLURM_ARRAY_TASK_ID + 7 ))
out_ix=$(( 9*$SLURM_ARRAY_TASK_ID + 8 ))

func_filepath=${paths_array[${func_ix}]}
anat_filepath=${paths_array[${anat_ix}]}
spinlr_filepath=${paths_array[${spinlr_ix}]}
spinrl_filepath=${paths_array[${spinrl_ix}]}
biasch_filepath=${paths_array[${biasch_ix}]}
biasbc_filepath=${paths_array[${biasbc_ix}]}
sbref_filepath=${paths_array[${sbref_ix}]}
params_filepath=${paths_array[${params_ix}]}

out_bind=${paths_array[${out_ix}]}
func_bind=`dirname $func_filepath`
anat_bind=`dirname $anat_filepath`
params_bind=`dirname $params_filepath`


func_file=`basename $func_filepath`
anat_file=`basename $anat_filepath`
spinlr_file=`basename $spinlr_filepath`
spinrl_file=`basename $spinrl_filepath`
biasch_file=`basename $biasch_filepath`
biasbc_file=`basename $biasbc_filepath`
sbref_file=`basename $sbref_filepath`
params_file=`basename $params_filepath`

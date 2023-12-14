#!/bin/bash

export SLURM_ARRAY_TASK_ID=0
module load singularity

export SUB_PATHS_FILE=/data/users2/jwardell1/nshor_docker/examples/hcp-project/HCP/paths

export SIF_FILE=/data/users2/jwardell1/nshor_docker/fmriproc.sif
export RUN_BIND_POINT=/data/users2/jwardell1/nshor_docker
export SCRIPT_NAME=pd_dockerParallelized.sh

export IFS=$'\n'
export paths_array=($(cat ${SUB_PATHS_FILE}))
export func_ix=$(( 9*$SLURM_ARRAY_TASK_ID ))
export anat_ix=$(( 9*$SLURM_ARRAY_TASK_ID + 1 ))
export spinlr_ix=$(( 9*$SLURM_ARRAY_TASK_ID + 2 ))
export spinrl_ix=$(( 9*$SLURM_ARRAY_TASK_ID + 3 ))
export biasch_ix=$(( 9*$SLURM_ARRAY_TASK_ID + 4 ))
export biasbc_ix=$(( 9*$SLURM_ARRAY_TASK_ID + 5 ))
export sbref_ix=$(( 9*$SLURM_ARRAY_TASK_ID + 6 ))
export params_ix=$(( 9*$SLURM_ARRAY_TASK_ID + 7 ))
export out_ix=$(( 9*$SLURM_ARRAY_TASK_ID + 8 ))

export func_filepath=${paths_array[${func_ix}]}
export anat_filepath=${paths_array[${anat_ix}]}
export spinlr_filepath=${paths_array[${spinlr_ix}]}
export spinrl_filepath=${paths_array[${spinrl_ix}]}
export biasch_filepath=${paths_array[${biasch_ix}]}
export biasbc_filepath=${paths_array[${biasbc_ix}]}
export sbref_filepath=${paths_array[${sbref_ix}]}
export params_filepath=${paths_array[${params_ix}]}

export out_bind=${paths_array[${out_ix}]}
export func_bind=`dirname $func_filepath`
export anat_bind=`dirname $anat_filepath`
export params_bind=`dirname $params_filepath`


export func_file=`basename $func_filepath`
export anat_file=`basename $anat_filepath`
export spinlr_file=`basename $spinlr_filepath`
export spinrl_file=`basename $spinrl_filepath`
export biasch_file=`basename $biasch_filepath`
export biasbc_file=`basename $biasbc_filepath`
export sbref_file=`basename $sbref_filepath`
export params_file=`basename $params_filepath`

# For dev use: 
#singularity exec --writable-tmpfs --bind $RUN_BIND_POINT:/run,$func_bind:/func,$anat_bind:/anat,$params_bind:/params,$out_bind:/out $SIF_FILE /run/${SCRIPT_NAME} -f $func_file -a $anat_file -c $biasch_file -b $biasbc_file -s $sbref_file -l $spinlr_file -r $spinrl_file -o $out_bind -p $params_file  &

# For prod use:
#singularity exec --writable-tmpfs --bind $func_bind:/func,$anat_bind:/anat,$params_bind:/params,$out_bind:/out $SIF_FILE /main.sh -f $func_file -a $anat_file -c $biasch_file -b $biasbc_file -s $sbref_file -l $spinlr_file -r $spinrl_file -o $out_bind -p $params_file &

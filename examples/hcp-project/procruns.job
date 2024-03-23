#!/bin/bash
#SBATCH -n 1
#SBATCH -c 4
#SBATCH --mem=64g
#SBATCH -p qTRD
#SBATCH --time=20:00:00
#SBATCH --exclude=arctrdcn009,arctrdcn010,arctrdcn011
#SBATCH -J PRPhcp
#SBATCH -e /data/users2/jwardell1/nshor_docker/examples/hcp-project/jobs/error%A_%a.err
#SBATCH -o /data/users2/jwardell1/nshor_docker/examples/hcp-project/jobs/out%A_%a.out
#SBATCH -A psy53c17
#SBATCH --mail-type=ALL
#SBATCH --mail-user=jwardell1@student.gsu.edu
#SBATCH --oversubscribe

sleep 5s

module load singularity



echo `hostname`
echo "SLURM_ARRAY_TASK_ID - $SLURM_ARRAY_TASK_ID"



SUB_PATHS_FILE=/data/users2/jwardell1/nshor_docker/examples/hcp-project/HCP/paths

SIF_FILE=/data/users2/jwardell1/nshor_docker/fmriproc.sif
#RUN_BIND_POINT=/data/users2/jwardell1/nshor_docker
#SCRIPT_NAME=pd_dockerParallelized.sh

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
echo "func_filepath - $func_filepath"
anat_filepath=${paths_array[${anat_ix}]} 
echo "anat_filepath - $anat_filepath"
spinlr_filepath=${paths_array[${spinlr_ix}]} 
echo "spinlr_filepath - $spinlr_filepath"
spinrl_filepath=${paths_array[${spinrl_ix}]} 
echo "spinrl_filepath - $spinrl_filepath"
biasch_filepath=${paths_array[${biasch_ix}]} 
echo "biasch_filepath - $biasch_filepath"
biasbc_filepath=${paths_array[${biasbc_ix}]} 
echo "biasbc_filepath - $biasbc_filepath"
sbref_filepath=${paths_array[${sbref_ix}]} 
echo "sbref_filepath - $sbref_filepath"
params_filepath=${paths_array[${params_ix}]} 
echo "params_filepath - $params_filepath"

out_bind=${paths_array[${out_ix}]} 
echo "out_bind - $out_bind"
func_bind=`dirname $func_filepath` 
echo "func_bind - $func_bind"
anat_bind=`dirname $anat_filepath` 
echo "anat_filepath - $anat_bind"
params_bind=`dirname $params_filepath` 
echo "params_filepath - $params_bind"


func_file=`basename $func_filepath` 
echo "func_file - $func_file"
anat_file=`basename $anat_filepath` 
echo "anat_file - $anat_file"
spinlr_file=`basename $spinlr_filepath` 
echo "spinlr_file - $spinlr_file"
spinrl_file=`basename $spinrl_filepath` 
echo "spinrl_file - $spinrl_file"
biasch_file=`basename $biasch_filepath` 
echo "biasch_file $biasch_file"
biasbc_file=`basename $biasbc_filepath` 
echo "biasbc_file - $biasbc_file"
sbref_file=`basename $sbref_filepath` 
echo "sbref_file - $sbref_file"
params_file=`basename $params_filepath` 
echo "params_file - $params_file"

# For dev use: 
#singularity exec --writable-tmpfs --bind $RUN_BIND_POINT:/run,$func_bind:/func,$anat_bind:/anat,$params_bind:/params,$out_bind:/out $SIF_FILE /run/${SCRIPT_NAME} -f $func_file -a $anat_file -c $biasch_file -b $biasbc_file -s $sbref_file -l $spinlr_file -r $spinrl_file -o $out_bind -p $params_file  &

# For prod use:
singularity exec --writable-tmpfs --bind $func_bind:/func,$anat_bind:/anat,$params_bind:/params,$out_bind:/out $SIF_FILE /main.sh -f $func_file -a $anat_file -c $biasch_file -b $biasbc_file -s $sbref_file -l $spinlr_file -r $spinrl_file -o $out_bind -p $params_file &


wait

sleep 10s


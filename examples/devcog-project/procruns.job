#!/bin/bash
#SBATCH -n 1
#SBATCH -c 4
#SBATCH --mem=64g
#SBATCH -p qTRD
#SBATCH --time=20:00:00
#SBATCH -J prpDEVCOG
#SBATCH -e /data/users2/jwardell1/nshor_docker/examples/devcog-project/jobs/error%A_%a.err
#SBATCH -o /data/users2/jwardell1/nshor_docker/examples/devcog-project/jobs/out%A_%a.out
#SBATCH -A psy53c17
#SBATCH --mail-type=ALL
#SBATCH --mail-user=jwardell1@student.gsu.edu
#SBATCH --oversubscribe

sleep 5s

module load singularity/3.10.2

SUB_PATHS_FILE=/data/users2/jwardell1/nshor_docker/examples/devcog-project/DEVCOG-ss/paths

SIF_FILE=/data/users2/jwardell1/nshor_docker/fmriproc.sif
#RUN_BIND_POINT=/data/users2/jwardell1/nshor_docker

#SLURM_ARRAY_TASK_ID=0

echo "SLURM_ARRAY_TASK_ID- $SLURM_ARRAY_TASK_ID"
hostname=`hostname`
echo "hostname- $hostname"

IFS=$'\n'
paths_array=($(cat ${SUB_PATHS_FILE}))
func_ix=$(( 4*$SLURM_ARRAY_TASK_ID ))
anat_ix=$(( 4*$SLURM_ARRAY_TASK_ID + 1 ))
json_ix=$(( 4*$SLURM_ARRAY_TASK_ID + 2 ))
out_ix=$(( 4*$SLURM_ARRAY_TASK_ID + 3 ))

func_filepath=${paths_array[${func_ix}]}
anat_filepath=${paths_array[${anat_ix}]}
json_filepath=${paths_array[${json_ix}]}

out_bind=${paths_array[${out_ix}]}
func_bind=`dirname $func_filepath`
anat_bind=`dirname $anat_filepath`

func_file=`basename $func_filepath`
anat_file=`basename $anat_filepath`
json_file=`basename $json_filepath`

echo "func_filepath = $func_filepath"
echo "anat_filepath = $anat_filepath"
echo "json_filepath = $json_filepath"
echo "out_bind = $out_bind"


#singularity exec --writable-tmpfs --bind $func_bind:/func,$anat_bind:/anat,$out_bind:/out $SIF_FILE /main.sh -f $func_file -a $anat_file -j $json_file -o $out_bind &
singularity exec --writable-tmpfs --bind $func_bind:/func,$anat_bind:/anat,$out_bind:/out $SIF_FILE /main.sh -f $func_file -a $anat_file -j $json_file -o $out_bind -n false &




wait

sleep 10s

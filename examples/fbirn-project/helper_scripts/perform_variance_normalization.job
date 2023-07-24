#!/bin/bash
#SBATCH -n 4
#SBATCH -c 4
#SBATCH --mem=32g
#SBATCH -p qTRD
#SBATCH --time=20:00:00
#SBATCH -J varnorm
#SBATCH -e /data/users2/jwardell1/nshor_docker/examples/fbirn-project/jobs/error%A.err
#SBATCH -o /data/users2/jwardell1/nshor_docker/examples/fbirn-project/jobs/out%A.out
#SBATCH -A psy53c17
#SBATCH --mail-type=ALL
#SBATCH --mail-user=jwardell1@student.gsu.edu
#SBATCH --oversubscribe

module load afni

BASEDIR=/data/users2/jwardell1/nshor_docker/examples/fbirn-project/FBIRN
OUTDIR=/data/users2/jwardell1/nshor_docker/examples/fbirn-project/FBIRN/group_mean_masks
CURDIR=`pwd`

subjects_file=/data/users2/jwardell1/nshor_docker/examples/fbirn-project/FBIRN/subjects.txt

cd $BASEDIR

IFS=$'\n' subject=($(cat "$subjects_file"))

idx=$SLURM_ARRAY_TASK_ID


# variance normalization
echo ${subject[idx]}

if [ -d ${subject[idx]}/ses_01/processed ]; then
	cd ${subject[idx]}/ses_01/processed
else
	exit
fi


proc_fmri=${subject[idx]}_rsfMRI_processed_rest.nii.gz
filename=rsfMRI_processed_rest

if [ -f v${filename}.nii ]; then 
	rm v${filename}.nii
fi

3dTstat -mean -stdev -mask $OUTDIR/groupmeanmask.nii \
		-prefix MeanStd.nii $proc_fmri &>/dev/null

3dcalc  -a $proc_fmri -b MeanStd.nii'[0]' -c MeanStd.nii'[1]' \
		-d $OUTDIR/groupmeanmask.nii \
		-expr "((a-b)/c + 100) * d" -prefix  v${filename}.nii &>/dev/null

chmod 777 `pwd`/v${filename}.nii

ln -sf `pwd`/v${filename}.nii $OUTDIR/${subject[idx]}_v${filename}.nii

wait 

sleep 10s

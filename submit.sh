#!/bin/bash
#SBATCH -n 1
#SBATCH -c 5
#SBATCH --mem=10g
#SBATCH -p qTRDHM
#SBATCH -t 0-01:00
#SBATCH -J watdks
#SBATCH -e /data/users2/washbee/tdassist/jobs/error%A.err
#SBATCH -o /data/users2/washbee/tdassist/jobs/out%A.out
#SBATCH --nodelist=arctrdhm001
#SBATCH -A psy53c17
#SBATCH --mail-type=ALL
#SBATCH --mail-user=washbee1@student.gsu.edu
#SBATCH --oversubscribe

sleep 5s

module load singularity/3.10.2

singularity exec --bind /data/users2/washbee/tdassist/ds004078-download/:/data /data/users2/washbee/tdassist/Dockerbuild/nshor2.sif /data/pd_dockerParralelized.sh ${SLURM_ARRAY_TASK_ID} 2>&1 &

wait

sleep 10s

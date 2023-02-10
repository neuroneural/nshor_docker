#!/bin/bash
#SBATCH -n 1
#SBATCH -c 4
#SBATCH --mem=5g
#SBATCH -p qTRD
#SBATCH -t 2-00:00
#SBATCH -J fbirn-test
#SBATCH -e /data/users2/jwardell1/fbirn-project/jobs/error%A.err
#SBATCH -o /data/users2/jwardell1/fbirn-project/jobs/out%A.out
#SBATCH -A psy53c17
#SBATCH --mail-type=ALL
#SBATCH --mail-user=jwardell1@student.gsu.edu
#SBATCH --oversubscribe

sleep 5s

module load singularity/3.10.2

singularity exec --bind .:/run/,/data/users2/jwardell1/fbirn-project/000300655084-download/:/data /data/users2/washbee/tdassist/Dockerbuild/nshor2.sif /run/pd_dockerParralelized_fbirn.sh &

wait

sleep 10s

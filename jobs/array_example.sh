#!/bin/bash
#SBATCH --time=00:15:00
#SBATCH --mem=200M
#SBATCH --output=array_example_%A_%a.out
#SBATCH --array=0-15
#SBATCH -n 1
#SBATCH -c 5
#SBATCH -p qTRD
#SBATCH -J arraytest
#SBATCH -e /data/users2/jwardell1/fbirn-project/jobs/error%A.err
#SBATCH -o /data/users2/jwardell1/fbirn-project/jobs/out%A.out
#SBATCH -A psy53c17
#SBATCH --mail-type=ALL
#SBATCH --mail-user=jwardell1@student.gsu.edu
#SBATCH --oversubscribe


sleep 5s


# You may put the commands below:

# Job step
srun echo "I am array task number" $SLURM_ARRAY_TASK_ID &

wait

sleep 10s

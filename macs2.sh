#!/bin/bash
#SBATCH --time=0:40:00
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --mem=12G
#SBATCH --cpus-per-task=6
#SBATCH -o log/slurmjob-%A-%a
#SBATCH --job-name=trim_atac
#SBATCH --partition=short
#SBATCH --array=0-5

echo "Identification les sites d'accessibilité"

# Handling errors
#set -x # debug mode on
set -o errexit # ensure script will stop in case of ignored error
set -o nounset # force variable initialisation
#set -o verbose
#set -euo pipefail
module purge
module load gcc/4.8.4 python/2.7.9 numpy/1.9.2 cython/0.25.2 MACS2/2.1.2

echo "Set up directories ..." >&2
#Set up the temporary directory
SCRATCHDIR=/storage/scratch/"$USER"/"$SLURM_JOB_ID"
OUTPUT="$HOME"/results/atacseq/MACS2
mkdir -p "$OUTPUT"
mkdir -p -m 700 "$SCRATCHDIR"
cd "$SCRATCHDIR"


#Set up data directory
DATA_DIR="/home/users/student05/results/atacseq/bam_net"
#Run the program
echo "Start on $SLURMD_NODENAME: "`date` >&2
tab=($(ls "$DATA_DIR"/*/*mapped*.bam))
SHORTNAME=($(basename "${tab[$SLURM_ARRAY_TASK_ID]}" .bam))

macs2 callpeak -t ${tab[$SLURM_ARRAY_TASK_ID]}  \
    --tempdir /storage/scratch/"$USER"/"$SLURM_JOB_ID" \
 	-f BAM \
	-n "$SHORTNAME" \
	--outdir "$SCRATCHDIR"

echo "List SCRATCHDIR: "
ls "$SCRATCHDIR" >&2
# Move results in one's directory
mv  "$SCRATCHDIR" "$OUTPUT"
echo "Stop job : "`date` >&2

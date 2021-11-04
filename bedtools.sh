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
module load gcc/4.8.4 bedtools/2.27.1

echo "Set up directories ..." >&2
#Set up the temporary directory
SCRATCHDIR=/storage/scratch/"$USER"/"$SLURM_JOB_ID"
OUTPUT="$HOME"/results/atacseq/peak_inter
mkdir -p "$OUTPUT"
mkdir -p -m 700 "$SCRATCHDIR"
cd "$SCRATCHDIR"


#Set up data directory
DATA_DIR="/home/users/student05/results/atacseq/MACS2"
#Run the program
echo "Start on $SLURMD_NODENAME: "`date` >&2
tab1=($(ls "$DATA_DIR"/*/*24h*_mapped_*.bed))
tab2=($(ls "$DATA_DIR"/*/*0h*_mapped_*.bed))
SHORTNAME=($(basename "${tab1[$SLURM_ARRAY_TASK_ID]}" .bed))

# intersect the peaks from both experiments.
# -f 0.50 combined with -r requires 50% reciprocal overlap between the
# peaks from each experiment.
bedtools intersect -a ${tab2[$SLURM_ARRAY_TASK_ID]} \
 -b ${tab1[$SLURM_ARRAY_TASK_ID]} \
 -f 0.50 -r > "$SCRATCHDIR"/"$SHORTNAME"_both.bed


echo "List SCRATCHDIR: "
ls "$SCRATCHDIR" >&2
# Move results in one's directory
mv  "$SCRATCHDIR" "$OUTPUT"
echo "Stop job : "`date` >&2

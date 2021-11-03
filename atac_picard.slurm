#!/bin/bash
#SBATCH --time=0:30:00
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --mem=30G
#SBATCH --cpus-per-task=6
#SBATCH -o log/slurmjob-%A-%a
#SBATCH --job-name=markdup_atac
#SBATCH --partition=short
#SBATCH --array=0-5

# Program configuration
__author__='DIOP Khadidiatou'

echo 'Removal of duplicates via Picard tools MarkDuplicates'

# Handling errors
#set -x # debug mode on
set -o errexit # ensure script will stop in case of ignored error
set -o nounset # force variable initialisation
#set -o verbose
#set -euo pipefail

#Set up whatever package we need to run with
module purge
module load gcc/8.1.0 java/oracle-1.11.0_11 picard/2.18.25 samtools/1.9

echo "Set up directories ..." >&2
#Set up the temporary directory
SCRATCHDIR=/storage/scratch/"$USER"/"$SLURM_JOB_ID"

OUTPUT="$HOME"/results/atacseq/picard
mkdir -p "$OUTPUT"
mkdir -p -m 700 "$SCRATCHDIR"
cd "$SCRATCHDIR"
#Set up data directory
DATA_DIR="$HOME/results/atacseq/bowtie2"

#Run the program
echo "Start on $SLURMD_NODENAME: "`date` >&2

echo "Make array of files to give to MarkDuplicates"
tab=($(find $DATA_DIR -type f -name "*_trim_mapped_sorted_q2.bam" ))

# Current filename
SHORTNAME=$(basename "${tab[$SLURM_ARRAY_TASK_ID]}" .bam )
echo "shortname = $SHORTNAME" >&2

java -jar /opt/apps/picard-2.18.25/picard.jar MarkDuplicates \
    I="${tab[$SLURM_ARRAY_TASK_ID]}" \
    O="$SHORTNAME"_cleaned.bam \
    M="$SHORTNAME"_duplicates.txt \
    REMOVE_DUPLICATES=true

echo "Indexing resulting bam file ..." >&2
samtools index -b "$SCRATCHDIR"/"$SHORTNAME"_cleaned.bam
echo "List SCRATCHDIR: "
ls "$SCRATCHDIR" >&2

#Move results from scratch to user one's directory
mv  "$SCRATCHDIR" "$OUTPUT"

echo "Stop job : "`date` >&2

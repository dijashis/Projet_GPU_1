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

# Program configuration
__author__='DIOP Khadidiatou'

echo 'Quality control and trimming'

# Handling errors
#set -x # debug mode on
set -o errexit # ensure script will stop in case of ignored error
set -o nounset # force variable initialisation
#set -o verbose
#set -euo pipefail

IFS=$'\n\t'

#Set up whatever package we need to run with
module purge
module load gcc/8.1.0 python/3.7.1 cutadapt


echo "Set up directories ..." >&2
#Set up the temporary directory
SCRATCHDIR=/storage/scratch/"$USER"/"$SLURM_JOB_ID"

OUTPUT="$HOME"/results/atacseq/trim
mkdir -p "$OUTPUT"
mkdir -p -m 700 "$SCRATCHDIR"
cd "$SCRATCHDIR"

#Set up data directory
DATA_DIR="/home/users/shared/data/atacseq/subset"

#Run the program
echo "Start on $SLURMD_NODENAME: "`date` >&2

echo "Set up 2 arrays with forward and reverse fastq.gz sequence files..." >&2
tab_fwd=($(ls "$DATA_DIR"/*_1.fastq.gz | sort -k9,9 ))
echo "tab_fwd = " >&2
printf '%s\n' "${tab_fwd[@]}" >&2

tab_rev=($(ls "$DATA_DIR"/*_2.fastq.gz | sort -k9,9))
echo "tab_rev = " >&2
printf '%s\n' "${tab_rev[@]}" >&2

echo "Run the trimming with cutadapt tool..." >&2
cutadapt -j ${SLURM_CPUS_ON_NODE} \
    -b file:"$HOME"/data/adapter_seqs.fa \
        -o $(basename "${tab_fwd[$SLURM_ARRAY_TASK_ID]}" .fastq.gz)_cutadapter1.fastq.gz \
        -p $(basename "${tab_rev[$SLURM_ARRAY_TASK_ID]}" .fastq.gz)_cutadapter2.fastq.gz \
    "${tab_fwd[$SLURM_ARRAY_TASK_ID]}" "${tab_rev[$SLURM_ARRAY_TASK_ID]}"


# Move results in one's directory
mv  "$SCRATCHDIR" "$OUTPUT"


echo "Stop job : "`date` >&2

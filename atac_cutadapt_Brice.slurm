#!/bin/bash
#SBATCH --time=1:00:00
#SBATCH --nodes=1
#SBATCH --ntasks=1
##SBATCH --mem=3G
#SBATCH --mem=12G
#SBATCH --cpus-per-task=6 
#SBATCH -o log/slurmjob-%A-%a
#SBATCH --job-name=cutadapt_atac
#SBATCH --partition=short
#SBATCH --array=0-5


__credits__=["brice.pertuisot"]


echo 'Cutadapt_Trimming'

# Handling errors
#set -x # debug mode on
set -o errexit # ensure script will stop in case of ignored error
set -o nounset # force variable initialisation
#set -o verbose
#set -euo pipefail

IFS=$'\n\t'

# Set up whatever package we need to run with
module purge
module load gcc/8.1.0 python/3.7.1 cutadapt/1.18


echo "Set up directories ..." >&2
# Set up the temporary directory
SCRATCHDIR=/storage/scratch/"$USER"/"$SLURM_JOB_ID"

OUTPUT="$HOME"/results/atacseq/cutadapt
mkdir -p "$OUTPUT"
mkdir -p -m 700 "$SCRATCHDIR"
cd "$SCRATCHDIR"

# Set up data directory
DATA_DIR="$HOME/data/atacseq/raw"
#DATA_DIR="$HOME/data/atacseq/raw"         !!!!!changer subset raw


# Run the program
echo "Start on $SLURMD_NODENAME: "`date` >&2

echo "Set up 2 arrays with forward and reverse fastq.gz sequence files..." >&2
tab_fwd=($(ls "$DATA_DIR"/*_1.fastq.gz))
echo "tab_fwd = " >&2
printf '%s\n' "${tab_fwd[@]}" >&2

tab_rev=($(ls "$DATA_DIR"/*_2.fastq.gz))
echo "tab_rev = " >&2
printf '%s\n' "${tab_rev[@]}" >&2

echo $(basename "${tab_fwd[$SLURM_ARRAY_TASK_ID]}" .fastq.gz )

echo "Run the trimming with cutadapt tool..." >&2


cutadapt -j 0 -a CTGTCTCTTATACACATCTCCGAGCCCACGAGAC -A CTGTCTCTTATACACATCTGACGCTGCCGACGA  \
    -o $(basename "${tab_fwd[$SLURM_ARRAY_TASK_ID]}" .fastq.gz)_trim_paired.fastq.gz \
    -p $(basename "${tab_rev[$SLURM_ARRAY_TASK_ID]}" .fastq.gz)_trim_paired.fastq.gz \
    --error-rate=0.1 --times=1 --overlap=3 --minimum-length=20 --pair-filter=any --quality-cutoff=20 \
    "${tab_fwd[$SLURM_ARRAY_TASK_ID]}" "${tab_rev[$SLURM_ARRAY_TASK_ID]}"

# Move results in one's directory
mv  "$SCRATCHDIR" "$OUTPUT"

echo "Stop job : "`date` >&2




#AR=('foo' 'bar' 'baz' 'bat')
#for i in "${!AR[@]}"; do
#  printf '${AR[%s]}=%s\n' "$i" "${AR[i]}"
#done

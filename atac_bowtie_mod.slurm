#!/bin/bash
##SBATCH --time=5:00:00
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --mem=30G
#SBATCH --cpus-per-task=8
#SBATCH -o log/slurmjob-%A-%a
#SBATCH --job-name=bowtie2_atac
#SBATCH --partition=short
#SBATCH --array=0-5

# Program configuration
__author__='DIOP Khadidiatou'

echo 'Alignment with bowtie2'

# Handling errors
#set -x # debug mode on
set -o errexit # ensure script will stop in case of ignored error
set -o nounset # force variable initialisation
#set -o verbose
#set -euo pipefail

#Set up whatever package we need to run with
module purge
module load gcc/4.8.4 bowtie2/2.3.4.3 samtools/1.3

echo "Set up directories ..." >&2

#Set up the temporary directory
SCRATCHDIR=/storage/scratch/"$USER"/"$SLURM_JOB_ID"

#Set up databank (index) directory
DATABANK=$HOME/data/ref/index
echo "index = $DATABANK"

OUTPUT="$HOME"/results/atacseq/bowtie2
mkdir -p "$OUTPUT"
mkdir -p -m 700 "$SCRATCHDIR"
cd "$SCRATCHDIR"

echo "Set up 2 arrays with trimmed forward and reverse fastq.gz sequence files..." >&2

tab_fwd=($(find "$HOME"/results/atacseq/trim -type f -name "*1_cutadapter.fastq.gz" -printf "%f %p \n" | sort -k1 | cut -d " " -f 2))
echo "tab_fwd = " >&2
printf '%s\n' "${tab_fwd[@]}" >&2

tab_rev=($(find "$HOME"/results/atacseq/trim -type f -name "*2_cutadapter.fastq.gz" -printf "%f %p \n" | sort -k1 | cut -d " " -f 2))
echo "tab_rev = " >&2
printf '%s\n' "${tab_rev[@]}" >&2

# Current filename
SHORTNAME=$(basename "${tab_fwd[$SLURM_ARRAY_TASK_ID]}" _1_cutadapter.fastq.gz )
echo "shortname = $SHORTNAME" >&2

# Run the program
echo "Start on $SLURMD_NODENAME: "`date` >&2

echo "Bowtie2 alignmment ..." >&2
# Args -X <int> : Max DNA fragment length (default 500bp)
# Args --sensitive : (default) but better alignment results are frequently achieved with --very-sensitive
# Args -k <int> : Max number of alignments to report per read. Default is 1 chosen randlomy if multiple
# Args -p <int> : Number of cores on which to run
echo "Apply quality mapping filter (q score) of at least 2 using Samtools ..." >&2
bowtie2  --very-sensitive -p 6 -k 10  -x "$DATABANK"/GRCm38 -1 "${tab_fwd[$SLURM_ARRAY_TASK_ID]}"  -2 "${tab_rev[$SLURM_ARRAY_TASK_ID]}"  \
  |  samtools view -q 2 -bS  -  |  samtools sort - -o "$SCRATCHDIR"/"$SHORTNAME"_trim_mapped_sorted_q2.bam

echo "Indexing mapped sorted bam file ..." >&2
samtools index -b "$SCRATCHDIR"/"$SHORTNAME"_trim_mapped_sorted_q2.bam
echo "List SCRATCHDIR: "
ls "$SCRATCHDIR" >&2

echo "Statistics on mapping ..." >&2
samtools idxstats "$SCRATCHDIR"/"$SHORTNAME"_trim_mapped_sorted_q2.bam > $OUTPUT/"$SHORTNAME".log

#Move results from scratch to user one's directory
mv  "$SCRATCHDIR" "$OUTPUT"

echo "Stop job : "`date` >&2

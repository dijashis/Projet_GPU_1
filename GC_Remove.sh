#!/bin/bash
##SBATCH --time=1:00:00
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --mem=30G
#SBATCH --cpus-per-task=8  
#SBATCH -o log/slurmjob-%A-%a
#SBATCH --job-name=Macs2_atac_corGC
#SBATCH --partition=short
#SBATCH --array=0-5



echo 'MACS2 Peak Calling after correctGCBias : dna accessibility sites'

# Handling errors
#set -x # debug mode on
set -o errexit # ensure script will stop in case of ignored error
set -o nounset # force variable initialisation
#set -o verbose
#set -euo pipefail

#Set up whatever package we need to run with
module purge
module load gcc/4.8.4 python/2.7.9 numpy/1.9.2 cython/0.25.2 cython/0.25.2 MACS2/2.1.2


echo "Set up directories ..." >&2

#Set up the temporary directory

SCRATCHDIR=/storage/scratch/"$USER"/"$SLURM_JOB_ID"
OUTPUT="$HOME"/results/atacseq/MACS2
TEMPDIR=/storage/scratch/$USER/macs2Temp/"$SLURM_JOB_ID"
mkdir -p "$OUTPUT"
mkdir -p -m 700 "$SCRATCHDIR"
mkdir -p -m 700 "$TEMPDIR"
cd "$SCRATCHDIR"

#Set up data directory
DATA_DIR="$HOME"/results/atacseq/correctedGCBias

#Set up 1 array with input names files for MACS2
echo "Set up 1 array with input names files for MACS2" >&2
tab=($(find "$DATA_DIR" -type f -name "*_trim_mapped_sorted_q2_lessDup*.bam"))
echo "tab = " >&2
printf '%s\n' "${tab[@]}" >&2
#tab=($(find "$DATA_DIR" -type f -name "*_lessDup.bam"))

# Current filename
SHORTNAME=$(basename "${tab[$SLURM_ARRAY_TASK_ID]::-4}" )
echo "shortname = $SHORTNAME" >&2




#Run the program
echo "Start on $SLURMD_NODENAME: "`date` >&2

# !!!!!!!!!!!!!!!!!!!à verif $DATA_DIR/*.bam   macs2 callpeak -t $DATA_DIR/*/*.bam\
macs2 callpeak -t "${tab[$SLURM_ARRAY_TASK_ID]}"\
 	-f BAM  \
	-n "$SHORTNAME"_macs2_atacSeq\
	--outdir "$SCRATCHDIR"\
	--tempdir "$TEMPDIR"
	
	

# Move results in user one's directory
mv  "$SCRATCHDIR" "$OUTPUT"

echo "Stop job : "`date` >&2

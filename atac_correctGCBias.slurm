#!/bin/bash
##SBATCH --time=1:00:00
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --mem=30G
#SBATCH --cpus-per-task=8  
#SBATCH -o log/slurmjob-%A-%a
#SBATCH --job-name=correctedGCBias
#SBATCH --partition=short
#SBATCH --array=0-5



echo 'DeepTools - correctGCBias'

# Handling errors
#set -x # debug mode on
set -o errexit # ensure script will stop in case of ignored error
set -o nounset # force variable initialisation
#set -o verbose
#set -euo pipefail

#Set up whatever package we need to run with
module purge
module load gcc/4.8.4 python/2.7.9 numpy/1.9.2 samtools/1.3 deepTools/3.1.2


#Set up the temporary directory
echo "Set up directories ..." >&2
SCRATCHDIR=/storage/scratch/"$USER"/"$SLURM_JOB_ID"
OUTPUT="$HOME"/results/atacseq/correctedGCBias
mkdir -p "$OUTPUT"
mkdir -p -m 700 "$SCRATCHDIR"
cd "$SCRATCHDIR"

#Set up data directory
DATA_DIR="$HOME"/rawData_Results/atacseq/MarkDuplicates

echo "Set up 1 array with input names BAM sorted files for correctGCBias" >&2
tab=($(find "$DATA_DIR" -type f -name "*_lessDup.bam"))

# Current filename  "$(basename "${tab_fwd[i]::-9}")"
SHORTNAME=$(basename "${tab[$SLURM_ARRAY_TASK_ID]::-4}")
echo "shortname = $SHORTNAME" >&2

#Run the program
echo "Start on $SLURMD_NODENAME: "`date` >&2

computeGCBias -b "${tab[$SLURM_ARRAY_TASK_ID]}" \
              --effectiveGenomeSize 2652783500 \
              -g /home/users/shared/databanks/bio/ncbi/genomes/Mus_musculus/Mus_musculus_GRCm38.p6/Mus_musculus_2020-7-9/2bit/all.2bit \
              --GCbiasFrequenciesFile "$SCRATCHDIR"/computeGCBias_freq.txt

correctGCBias -b "${tab[$SLURM_ARRAY_TASK_ID]}" \
   --effectiveGenomeSize 2652783500 \
   --genome /home/users/shared/databanks/bio/ncbi/genomes/Mus_musculus/Mus_musculus_GRCm38.p6/Mus_musculus_2020-7-9/2bit/all.2bit \
   --GCbiasFrequenciesFile "$SCRATCHDIR"/computeGCBias_freq.txt \
   -o "$SHORTNAME"_gc_cor.bam


# Move results in user one's directory
mv  "$SCRATCHDIR" "$OUTPUT"

echo "Stop job : "`date` >&2
	

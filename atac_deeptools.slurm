#!/bin/bash
#SBATCH --time=0:30:00
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --mem=30G
#SBATCH --cpus-per-task=6
#SBATCH -o log/slurmjob-%A-%a
#SBATCH --job-name=deepT
#SBATCH --partition=short
#SBATCH --array=0-5

# Program configuration
__author__='DIOP Khadidiatou'

echo 'Analysis via deepTools'

# Handling errors
#set -x # debug mode on
set -o errexit # ensure script will stop in case of ignored error
set -o nounset # force variable initialisation
#set -o verbose
#set -euo pipefail

#Set up whatever package we need to run with
module purge
module load gcc/4.8.4 python/2.7.9 numpy/1.9.2 samtools/1.3 deepTools/3.1.2

echo "Set up directories ..." >&2
#Set up the temporary directory
SCRATCHDIR=/storage/scratch/"$USER"/"$SLURM_JOB_ID"

OUTPUT="$HOME"/results/atacseq/deeptools
mkdir -p "$OUTPUT"
mkdir -p -m 700 "$SCRATCHDIR"
cd "$SCRATCHDIR"
#Set up data directory
DATA_DIR="$HOME/results/atacseq/picard"

#Run the program
echo "Start on $SLURMD_NODENAME: "`date` >&2

echo "Make array of files to give to MarkDuplicates"
tab=($(find $DATA_DIR -type f -name "*_cleaned.bam" ))

# Current filename
SHORTNAME=$(basename "${tab[$SLURM_ARRAY_TASK_ID]}" .bam )
echo "shortname = $SHORTNAME" >&2

multiBamSummary bins \
	-b $DATA_DIR/*/*.bam \
	-o covmat.npz
plotCorrelation -in covmat.npz \
        --corMethod spearman \
        --whatToPlot heatmap \
        --plotTitle "This is a test" \
        -o testplot.png

plotCoverage --bamfiles $tab \
    --plotFile "$OUTPUT"/coverage \
    --plotTitle "Coverage" \
    --outRawCounts coverage.tab \
    --ignoreDuplicates

#Move results from scratch to user one's directory
mv  "$SCRATCHDIR" "$OUTPUT"

echo "Stop job : "`date` >&2

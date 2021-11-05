#!/bin/bash
#SBATCH --time=0:30:00
#SBATCH --nodes=1
#SBATCH --ntasks=1
##SBATCH --mem=3G
#SBATCH --mem-per-cpu=2G
#SBATCH --cpus-per-task=8 
#SBATCH -o log/slurmjob-%A-%a
#SBATCH --job-name=qc_atac
#SBATCH --partition=short
#SBATCH --array=0-11

# Program configuration
__author__='Nadia Goué'
__email__='nadia.goue@uca.fr'
__credits__=["Nadia Goué"]
__license__='GPL3'
__maintainer__='Nadia Goué'
__status__='Development'
__version__='0.0.1'

echo 'Quality control'

# Handling errors
#set -x # debug mode on
set -o errexit # ensure script will stop in case of ignored error
set -o nounset # force variable initialisation
#set -o verbose
#set -euo pipefail



# Upload whatever required packages
module load java/oracle-1.7.0_79 fastqc/0.11.7 

echo "Set up directories ..." >&2
# Set up data and result directories
# Run QC on raw data and an trimmed data
DATA_DIR=/home/users/shared/data/atacseq/subset

echo "Set up an array with all fastq.gz sequence files..." >&2
tab=($(ls "$DATA_DIR"/*.fastq.gz))
echo "tab = " >&2
printf '%s\n' "${tab[@]}" >&2

# Set up the temporary directory
#SCRATCHDIR=/storage/scratch/"$USER"/"$SLURM_JOB_ID"
shortname=($(basename "${tab[$SLURM_ARRAY_TASK_ID]}" .fastq.gz ))

#SCRATCHDIR=/storage/scratch/"$USER"/"$shortname"
SCRATCHDIR=/storage/scratch/"$USER"/"$shortname"/fastqc-init

OUTPUT="$HOME"/results/atacseq/qc/"$shortname"
mkdir -p "$OUTPUT"
# Look for empty result directory
if [ -d "$OUTPUT/fastqc-init" ]
then
    if [ "$(ls -A $OUTPUT/fastqc-init)" ]; then
    echo "$OUTPUT/fastqc-init is not empty and must be cleaned."
    rm -rf "$OUTPUT"/fastqc-init
    else
    echo "Directory $OUTPUT/fastq-init is empty."
    fi
fi

mkdir -p -m 700 "$SCRATCHDIR"

cd "$SCRATCHDIR"
mkdir -p "$SCRATCHDIR"

# Run the program
echo "Start on $SLURMD_NODENAME: "`date` >&2

echo "Run the initial quality control... " >&2
#fastqc "${tab[$SLURM_ARRAY_TASK_ID]}" -dir $SCRATCHDIR -o "$SCRATCHDIR"/fastqc-init
fastqc "${tab[$SLURM_ARRAY_TASK_ID]}" -dir "$SCRATCHDIR" -o "$SCRATCHDIR"
#mv "$SCRATCHDIR"/fastqc-init "$OUTPUT"
mv "$SCRATCHDIR" "$OUTPUT"

# Cleaning in case something went wrong
rm -rf  "$SCRATCHDIR"
#rm -rf  "$SCRATCHDIR"/fastqc-init

echo "Stop job : "`date` >&2




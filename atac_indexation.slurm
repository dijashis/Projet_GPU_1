#!/bin/bash
#SBATCH --time=1:40:00
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --mem=12G
#SBATCH --cpus-per-task=2
#SBATCH -o log/slurmjob-%A-%a
#SBATCH --job-name=indexGRCm38_atac
#SBATCH --partition=short

# Program configuration
__author__='DIOP Khadidiatou'

echo 'Indexation of GRCm38 genome for alignment'

# Handling errors
#set -x # debug mode on
set -o errexit # ensure script will stop in case of ignored error
set -o nounset # force variable initialisation
#set -o verbose
#set -euo pipefail

IFS=$'\n\t'

#Set up whatever package we need to run with
module purge
module load gcc/8.1.0 bowtie2/2.3.4.3


echo "Set up directories ..." >&2
# Set up data directory
DATA_DIR="/home/users/student10/data/ref"
# Set up the temporary directory
SCRATCHDIR=/storage/scratch/"$USER"/"$SLURM_JOB_ID"
# Set up output directory
OUTPUT="$DATA_DIR"/index
mkdir -p "$OUTPUT"
mkdir -p -m 700 "$SCRATCHDIR"
cd "$SCRATCHDIR"

#Run the program
echo "Start on $SLURMD_NODENAME: "`date` >&2

bowtie2-build "$DATA_DIR"/all.fasta 'GRCm38'


# Move results in one's directory
mv  "$SCRATCHDIR"/* "$OUTPUT"
rm -rf "$SCRATCHDIR"

echo "Stop job : "`date` >&2

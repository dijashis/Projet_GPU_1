#! /bin/bash
#cd "$(dirname "$0")"

echo 'Team 4 (Universite Clermont Auvergne, Mesocentre)'
echo 'Date: Fall Master course 2021 '
echo 'Object: Sample case of ATACseq workflow showing job execution and dependen
cy handling.'
echo 'Inputs: paths to scripts qc, trim and bowtie2, atac_rem_dup, atacseq_deepl, atac_macs, atac_bedtools'
echo 'Outputs: trimmed fastq files, QC HTML files and BAM files, BED files, .npz files, .tab files, .png files, (.narrowPeak, .xls, .r files)'

# Handling errors
#set -x # debug mode on
set -o errexit # ensure script will stop in case of ignored error
set -o nounset # force variable initialisation
#set -o verbose

IFS=$'\n\t'

echo "Launching Atac-seq Workflow"
# first job - no dependencies
# Initial QC
jid1=$(sbatch --parsable scripts/atac_qc_init.slurm)
echo "$jid1 : Initial Quality Control"

# Trimming
jid2=$(sbatch --parsable --dependency=afterok:$jid1 scripts/atac_trim.slurm)
echo "$jid2 : Trimming with Trimmomatic tool"

# Post QC
jid3=$(sbatch --parsable --dependency=afterok:$jid2 scripts/atac_qc_post.slurm)
echo "$jid3 : Post control_quality"

# Bowtie2 Alignment
jid4=$(sbatch --parsable --dependency=afterok:$jid3 scripts/atac_bowtie2.slurm)
echo "$jid4 : Sequence Alignment Using Bowtie2 "

# Cleaning Alignments
jid5=$(sbatch --parsable --dependency=afterok:$jid4 scripts/atac_rem_dup.slurm)
echo "$jid5 : Cleaning alignments Using Picard Tools"

#  Data Exploitation
jid6=$(sbatch --parsable --dependency=afterok:$jid5 scripts/atacseq_deepl)
echo "$jid6 : Exploiting The Data Using DeepTools"

#  Identification of dna accessibility sites
jid7=$(sbatch --parsable --dependency=afterok:$jid6 scripts/atac_macs)
echo "$jid7 : Identification of dna accessibility sites using MACS2"

#  Identification of common accessibility sites
jid8=$(sbatch --parsable --dependency=afterok:$jid7 scripts/atac_bedtools)
echo "$jid8 : Identification of common accessibility sites using BedTools"

#  Info on workflow
jid9=$(sbatch --parsable --dependency=afterok:$jid8 scripts/)
echo "$jid9 : Get general info from worflow"


echo "Stop job : "`date` >&2
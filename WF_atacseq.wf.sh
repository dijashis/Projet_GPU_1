#! /bin/bash
#cd "$(dirname "$0")"

echo 'Groupe 1 : projet HPC '
echo 'Date: Fall Master course 2021 '
echo 'Object: ATAC-SEQ'
echo 'Inputs: paths to scripts'
echo 'Outputs: trimmed fastq files, QC HTML files, BAM and BEDfiles'

# Handling errors
#set -x # debug mode on
set -o errexit # ensure script will stop in case of ignored error
set -o nounset # force variable initialisation
#set -o verbose

IFS=$'\n\t'

rm -f /home/users/"$USER"/results/performance_workflow.txt

# first job - no dependencies

# Initial QC
jid1=$(sbatch --parsable scripts/atac_qc_init.slurm)
sbatch --dependency=afterok:$jid1 /home/users/"$USER"/scripts/performance.slurm "$jid1"
echo "$jid1 : Initial Quality Control"

# Trimming with cutadapt
jid2=$(sbatch --parsable --dependency=afterok:$jid1 scripts/atac_cutadapt.slurm)
sbatch --dependency=afterok:$jid2 /home/users/"$USER"/scripts/performance.slurm "$jid2"
echo "$jid2 : Trimming with cutadapt"


# Post QC
jid3=$(sbatch --parsable --dependency=afterok:$jid2 scripts/atac_qc_post_mod.slurm)
sbatch --dependency=afterok:$jid3 /home/users/"$USER"/scripts/performance.slurm "$jid3"
echo "$jid3 : Post Quality Control"

#bowtie2-build : builds a Bowtie index from Mus_musculus_GRCm38
#jid4=$(sbatch --parsable --dependency=afterok:$jid3 script/atac_indexation.slurm)
#sbatch --dependency=afterok:$jid4 /home/users/"$USER"/scripts/performance.slurm "$jid4"
#echo "$jid4: Building a Bowtie index from Mus_musculus_GRCm38"


# Bowtie2 : alignment
jid5=$(sbatch --parsable --dependency=afterok:$jid3 scripts/atac_bowtie2_mod.slurm)
sbatch --dependency=afterok:$jid5 /home/users/"$USER"/scripts/performance.slurm "$jid5"
echo "$jid5: Alignment"

# Picard.jar, MarkDuplicates : removing duplicates 
jid6=$(sbatch --parsable --dependency=afterok:$jid5 scripts/atac_picard.slurm)
sbatch --dependency=afterok:$jid6 /home/users/"$USER"/scripts/performance.slurm "$jid6"
echo "$jid6: Removing duplicates with Picard Tool MarkDuplicates"

# DeepTools - User-friendly tools for exploring deep-sequencing data; BAM files analysis
jid7=$(sbatch --parsable --dependency=afterok:$jid6 scripts/atac_deeptools.slurm)
sbatch --dependency=afterok:$jid7 /home/users/"$USER"/scripts/performance.slurm "$jid7"
echo "$jid7: DeepTools : BAM files analysis"

# MACS2 Peak Calling : dna accessibility sites
jid8=$(sbatch --parsable --dependency=afterok:$jid7 script/atac_macs.slurm)
sbatch --dependency=afterok:$jid8 /home/users/"$USER"/scripts/performance.slurm "$jid8"
echo "$jid8: MACS2 Peak Calling : dna accessibility sites."

# Bedtools intersect ; searching for uniques and common accessibility sites between the different cellular stages
jid9=$(sbatch --parsable --dependency=afterok:$jid8 script/atac_bedTools.slurm)
sbatch --dependency=afterok:$jid9 /home/users/"$USER"/scripts/performance.slurm "$jid9"
echo "$jid9 : Bedtools intersect ; searching for uniques and common accessibility sites between the different cellular stages."
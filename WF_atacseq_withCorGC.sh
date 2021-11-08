#! /bin/bash
#cd "$(dirname "$0")"
#SBATCH -o log/slurmjob-%A-%a

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

# !! Data collected during the run of jid1 to jid7 of WF_atacseq.wf.sh are necessary !! see /home/users/student22/rawData_Results/atacseq/MarkDuplicates

# first job - no dependencies

# DeepTools - correctGCBias
jid7=$(sbatch --parsable script/atac_correctGCBias_Brice.slurm)
sbatch --dependency=afterok:$jid7 /home/users/"$USER"/script/performance.slurm "$jid7"
echo "$jid7: DeepTools - correctGCBias"

# MACS2 Peak Calling : dna accessibility sites
jid8=$(sbatch --parsable  script/atac_corGC_Macs2_Brice.slurm)  # --dependency=afterok:$jid7   !!! à remettre
sbatch --dependency=afterok:$jid8 /home/users/"$USER"/script/performance.slurm "$jid8"
echo "$jid8: MACS2 Peak Calling : dna accessibility sites."

# Bedtools intersect ; searching for uniques and common accessibility sites between the different cellular stages
jid9=$(sbatch --parsable --dependency=afterok:$jid8 script/atac_corGC_bedTools_Brice.slurm)
sbatch --dependency=afterok:$jid9 /home/users/"$USER"/script/performance.slurm "$jid9"
echo "$jid9 : Bedtools intersect ; searching for uniques and common accessibility sites between the different cellular stages."

#!/bin/bash
#SBATCH --time=0:40:00
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --mem=2G
#SBATCH -o log/slurmjob-%A-%a
#SBATCH --job-name=Sacct
#SBATCH --partition=short
sacct --format=jobid,elapsed,ncpus,AllocCPUS,CPUTime,TotalCPU,ReqMem,ntasks,state,User > Info_workflow.txt

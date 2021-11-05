#!/bin/bash
#SBATCH -o log/slurmjob_perf-%j
#SBATCH --partition=long

sacct -a -o JobID,State,ReqCPUS,ReqMem,Elapsed,CPUTime,MaxRSS,Start,Partition -j "$1" -s CD >> "$HOME"/results/performance_workflow.txt
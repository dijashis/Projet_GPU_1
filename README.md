# Projet_HPC

Scripts required to execute a workflow with the purpose of finding DNA accessibility sites from ATAC-seq data.

Use : individual scripts can be used for a step-by-step approach, or the workflow scripts can be used to execute the entire workflow.

## Workflow scripts

Worflow (WF) files allow for execution of every necessary step of the workflow, with some steps added or removed based on specific needs.
WF_atacseq.wf.sh is the default workflow.
Can be used independantly.

WF_atacseq_sansIndexage.sh does not handle reference genome indexing, assuming it has already been dealt with. This is useful because the indexing takes a long time, and is not a step that needs to be repeated if already achieved for the reference genome used.
Can be used independantly.

WF_atacseq_withCorGC.sh employs a GC bias correction tool.
Requires that the results of steps 1 through 7 of WF_atacseq.wf.sh are already completed to execute properly ! Do not use without modification before completing these steps !

## Individual steps (in order of workflow execution)

### Initial quality control
Uses fastqc to execute a quick initial quality control of the sequencing results. Takes fastq input by default.

### Trimming
Removal of adapters via cutadaptc. If you wish to use this for another analysis with similar workflow, be sure to change the adapter sequences used as needed. Takes fastq input, gives fastq output.

### Post-trimming quality control
Once trimming has been finished, another quality control step is executed, via fastqc once again. Takes fastq input.

### Reference genome indexing (optional)
This step allows for the indexing of the reference genome used for the alignment which follows. Unnecessary if the indexing has already been achieved. bt2 output

### Alignment with reference genome
In this step bowtie2 is used to align the sequencing results with the reference genome, then samtools is used for file conversion (sam -> bam) and sorting. Takes bt2 (ref genome index) and fastq (sequencing data) input, gives bam output.

### Removal of duplicates
Picard is used here, specifically the MarkDuplicates tool. It is used with the REMOVE_DUPLICATES option set to true so that the result files have the duplicates removed rather than just marked. Takes bam input, gives bam (data with duplicated removed) and txt (info on duplicates) output.

### Exploration via deepTools
This step produces plots to analyse correlation and coverage for the now aligned sequencing data, through the use of python-coded deepTools. Takes bam input, provides pdf files for plots, and a .tab correlation matrix file.

### GC bias correction (optional)
Handles GC bias correction via deeptools' computeGCBias & correctGCBias tools. Takes bam input, gives bam (data with GC correction) and txt (computeGCBias analysis results) output.

### Identification of DNA accessibility sites
The MACS2 callpeak tool is used to find the accessibility sites within the aligned sequencing data. Takes bam input, gives narrowPeak, wig, and bed output.

### Comparison of DNA accessibility sites between conditions
Obtains via bedtools, from MACS2 callpeak results, the unique/common accessibility sites between conditions (T0h and T24h). Takes bed input, gives bed output.

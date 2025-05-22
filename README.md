# WDV-Bioinformatics-Pipeline
A bioinformatics pipeline for Wheat Dwarf Virus (WDV) genomic data analysis.
# Wheat Dwarf Virus (WDV) Genomic Analysis Pipeline

## Project Overview

This repository documents a bioinformatics pipeline developed for the analysis of Wheat Dwarf Virus (WDV) genomic data. The pipeline covers essential steps from raw sequence data quality control and trimming, alignment to reference genomes, variant calling, and functional annotation. This work was part of a broader study on the epidemiology of Wheat Dwarf Virus, particularly focusing on sequence variation.

## Motivation

Understanding the genomic characteristics and variations within WDV populations is crucial for epidemiological studies and developing effective disease management strategies in cereals. This pipeline was developed to process Next-Generation Sequencing (NGS) data to identify single nucleotide polymorphisms (SNPs) and other variations within WDV isolates.

## Key Features

* **Quality Control & Trimming**: Utilizes `fastx_trimmer` and `Trimmomatic` for read quality assessment and adapter/low-quality base removal.
* **Reference Alignment**: Employs `Bowtie2` for accurate mapping of sequencing reads to WDV reference genomes and phytoplasma plasmids.
* **BAM File Processing**: Includes steps for converting SAM to BAM, sorting, and indexing BAM files using `SAMTOOLS`.
* **Variant Calling**: Implements `BCFtools` for robust SNP and indel calling.
* **Functional Annotation**: Utilizes `SnpEff` for annotating genetic variants based on known genomic features.
* **Reproducible Workflow**: Scripts are organized to facilitate running the pipeline on HPC environments like Uppmax.

## Getting Started

### Prerequisites

* Access to an HPC cluster (e.g., Uppmax, with `ssh` access).
* Necessary bioinformatics tools loaded as modules or installed:
    * `Fastx` (e.g., `Fastx/0.0.14`) [cite: 1]
    * `Trimmomatic` (e.g., `trimmomatic 0.36`) [cite: 6]
    * `SAMTOOLS` [cite: 8]
    * `BedTools` [cite: 12] (though `samtools bam2fq` was also used for bam to fastq conversion) [cite: 15]
    * `Bowtie2`
    * `BCFtools` (e.g., integrated with `SAMTOOLS`) [cite: 31]
    * `SnpEff` (e.g., `snpEff/4.3t`) [cite: 74, 78, 89]
    * `FastQC` (for quality assessment, though not explicitly shown in detail, it's a standard QC tool)

### Installation/Setup (for Uppmax example)

1.  **SSH into Uppmax**:
    ```bash
    ssh elhamy@rackham.uppmax.uu.se
    ```
2.  **Copy Input Files**: Transfer your BAM files and reference genomes to your project directory on Uppmax.
    ```bash
    scp /Users/emya0001/Documents/Wdvtrial-Aug18/bamfile/rp_010_2.bam elhamy@rackham.uppmax.uu.se:/home/elhamy/snic2018-8-322/wdvfiles
    # Copy other necessary files like reference fasta (ENK1.fasta, pWBD1.fasta, pWBDs.fasta) and genes.gbk
    ```
3.  **Load Modules**: Ensure you load the required bioinformatics modules before running scripts. These can be put at the top of your scripts.
    ```bash
    module load bioinfo-tools
    module load Fastx/0.0.14
    module load trimmomatic/0.36 # Example, check exact version
    module load samtools # This usually includes bcftools
    module load bowtie2 # Example, check exact version
    module load snpEff/4.3t
    module load fastqc # For quality checking
    ```

## Pipeline Workflow

This pipeline processes raw sequencing data through several key steps.

### Step 1: Preprocessing and Quality Control (`scripts/01_preprocessing.sh`)

This script handles initial read quality assessment and trimming.

```bash
#!/bin/bash

# Load modules
module load bioinfo-tools
module load Fastx/0.0.14
module load trimmomatic/0.36 # Adjust version as needed
module load fastqc # Adjust version as needed

# Define input/output files (adjust paths as per your project structure)
INPUT_FASTQ_1="rp_010_1.1.unmapped.fastq" # Example: Assuming initial unmapped fastq
INPUT_FASTQ_2="rp_010_2-1-trimmed-3.fastq" # Example: Later stage trimmed fastq for further trimming

OUTPUT_FASTQ_1_TRIMMED_UT="rp_010_1.1.ut.fastq"
OUTPUT_FASTQ_1_TRIMMED_4="rp_010_1-1-trimmed-4.fastq"
OUTPUT_FASTQ_2_TRIMMED_4="rp_010_2-1-trimmed-4.fastq"
OUTPUT_FASTQ_2_TRIMMED_5="rp_010_2-1-trimmed-5.fastq"
OUTPUT_FASTQ_2_TRIMMED_6="rp_010_2-1-tr-6.fastq"


# 1. FASTA/Q Trimmer (fastx_trimmer)
# Trimming based on first base (f), last base (l), and minimum length (m)
# Example usage from documentation: fastx_trimmer -f 1 -l 400 -t 219 -m 400 -z -v -i rp_010_1.1.unmapped.fastq -o rp_010_1.1.ut.fastq [cite: 1]
# Based on your log, you used specific trimming parameters:
echo "Running fastx_trimmer (first pass)..."
fastx_trimmer -f 1 -l 400 -t 219 -m 400 -z -v -i ${INPUT_FASTQ_1} -o ${OUTPUT_FASTQ_1_TRIMMED_UT} [cite: 1]

echo "Running fastx_trimmer (second pass for rp_010_2-1-trimmed-3.fastq)..."
# Trimming from base 10 to 400
fastx_trimmer -f 10 -l 400 -v -i ${INPUT_FASTQ_2} -o ${OUTPUT_FASTQ_2_TRIMMED_4} [cite: 28]

echo "Running fastx_trimmer (rp_010_1-1-trimmed-3.fastq)..."
fastx_trimmer -f 10 -l 400 -v -i rp_010_1-1-trimmed-3.fastq -o ${OUTPUT_FASTQ_1_TRIMMED_4} [cite: 28]

echo "Running fastx_trimmer (rp_010_2-1-trimmed-3.fastq to trimmed-5.fastq)..."
# Trimming from base 10 to 350
fastx_trimmer -f 10 -l 350 -v -i rp_010_2-1-trimmed-3.fastq -o ${OUTPUT_FASTQ_2_TRIMMED_5} [cite: 32]

echo "Running fastx_trimmer (rp_010_2-1-trimmed-3.fastq to tr-6.fastq)..."
# Trimming from base 10 to 360
fastx_trimmer -f 10 -l 360 -v -i rp_010_2-1-trimmed-3.fastq -o ${OUTPUT_FASTQ_2_TRIMMED_6} [cite: 33]

# 2. Quality Check (FastQC)
echo "Running FastQC on trimmed files..."
fastqc ${OUTPUT_FASTQ_2_TRIMMED_4} [cite: 28]
fastqc ${OUTPUT_FASTQ_1_TRIMMED_4} [cite: 28]
fastqc ${OUTPUT_FASTQ_2_TRIMMED_5} [cite: 32]
fastqc ${OUTPUT_FASTQ_2_TRIMMED_6} [cite: 32]

# 3. Trimmomatic (if used for adapter removal or more advanced trimming)
# Usage: Trimmomatic PE <inputFile1> <inputFile2> <outputFile1P> <outputFile1U> <outputFile2P> <outputFile2U> <trimmer1>... [cite: 6]
# Although specific Trimmomatic commands are not fully detailed in the log, it's listed as a tool.
# Example (if you used it):
# trimmomatic PE -phred33 input_R1.fastq input_R2.fastq output_R1_paired.fastq output_R1_unpaired.fastq output_R2_paired.fastq output_R2_unpaired.fastq ILLUMINACLIP:adapters.fa:2:30:10 LEADING:3 TRAILING:3 SLIDINGWINDOW:4:15 MINLEN:36

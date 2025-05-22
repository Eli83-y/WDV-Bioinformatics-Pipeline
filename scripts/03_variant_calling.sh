#!/bin/bash

# Load modules
module load bioinfo-tools
module load samtools # Adjust version as needed (includes bcftools)

# Define input/output files (adjust paths)
INPUT_SAM_1="rp_010_1-1-trimmed-4.sam"
INPUT_SAM_2="rp_010_2-1-trimmed-4.sam"
INPUT_SAM_6="rp_010_2-1-tr-6.sam"
INPUT_SAM_6_2="rp_010_2-1-tr-6.2.sam" # For -U alignment

REF_FASTA="ENK1.fasta" # Reference genome for variant calling

# SAM to BAM conversion, sorting, and indexing
echo "Converting SAM to BAM, sorting, and indexing..."

# Process rp_010_1-1-trimmed-4.sam
samtools view -hSbo rp_010_1-1-trimmed-4.bam ${INPUT_SAM_1} [cite: 30]
samtools sort -o rp_010_1-1-tr-sor-4.bam rp_010_1-1-trimmed-4.bam [cite: 30]
samtools index rp_010_1-1-tr-sor-4.bam # Important for mpileup and IGV

# Process rp_010_2-1-trimmed-4.sam
samtools view -hSbo rp_010_2-1-trimmed-4.bam ${INPUT_SAM_2} [cite: 30]
samtools sort -o rp_010_2-1-tr-sor-4.bam rp_010_2-1-trimmed-4.bam [cite: 30]
samtools index rp_010_2-1-tr-sor-4.bam # Important for mpileup and IGV

# Process rp_010_2-1-tr-6.sam
samtools view -hSbo rp_010_2-1-tr-6.bam ${INPUT_SAM_6} [cite: 34]
samtools sort -o rp_010_2-1-tr-sor-6.bam rp_010_2-1-tr-6.bam [cite: 34]
samtools index rp_010_2-1-tr-sor-6.bam [cite: 34]

# Variant Calling with BCFtools
echo "Performing variant calling with BCFtools..."

# Example 1: Original BCFtools call
bcftools mpileup -Ou -f ${REF_FASTA} rp_010_2-1-trimmed-sor-4.1.bam | bcftools call -mv -Ob -o calls.bcf [cite: 31]

# Example 2: From your later logs
samtools mpileup -g -f ${REF_FASTA} rp_010_2-1-tr-sor-6.bam > rp_010_2-1-tr-raw-6.bcf [cite: 34]
bcftools call -O b -vc rp_010_2-1-tr-raw-6.bcf > rp_010_2-1-tr-var-6.vcf [cite: 34]

# Filtering variants with vcfutils.pl (part of samtools package)
# Note: vcfutils.pl is often part of older samtools distributions. For newer bcftools, filtering might be done directly with bcftools view -f.
bcftools view rp_010_2-1-tr-var-6.vcf | vcfutils.pl varFilter - > rp_010_2-1-tr-var-6-final.vcf [cite: 37]

# Alternative BCFtools call with ploidy 1 (as seen in your log)
# bcftools call --ploidy 1 -m -v -o rp_010_2-1-tr-var-6-final.vcf rp_010_2-1-tr-raw-6.bcf # Recheck this command for correctness [cite: 39]

echo "Variant calling complete. VCF files are generated."

# Optional: Check number of variants (as in your log)
# grep -v "#" rp_010_2-1-tr-var-6-final.vcf | wc -l [cite: 39]
# grep -v "#" rp_010_1-1-tr-var-final.vcf | wc -l [cite: 40]


#!/bin/bash

# Load modules
module load bioinfo-tools
module load bowtie2 # Adjust version as needed

# Define reference genomes (ensure these are built and indexed)
REF_ENK1="ENK1" # Assuming ENK1.fasta was used to build the index
REF_ENK2="WDV-Enk2" # Assuming WDV-Enk2.fasta was used to build the index
REF_PWBD1="pWBD1" # Assuming pWBD1.fasta was used to build the index
REF_PWBDS="pWBDs" # Assuming pWBDs.fasta was used to build the index

# Define input/output files (adjust paths as per your project structure)
INPUT_FASTQ_1_TRIMMED="rp_010_1-1-trimmed-3.fastq"
INPUT_FASTQ_2_TRIMMED="rp_010_2-1-trimmed-3.fastq"
INPUT_FASTQ_1_TRIMMED_4="rp_010_1-1-trimmed-4.fastq"
INPUT_FASTQ_2_TRIMMED_4="rp_010_2-1-trimmed-4.fastq"
INPUT_FASTQ_2_TRIMMED_6="rp_010_2-1-tr-6.fastq"


# Build Bowtie2 indexes (if not already built - you usually do this once per reference)
# bowtie2-build ENK1.fasta ENK1
# bowtie2-build WDV-Enk2.fasta WDV-Enk2
# bowtie2-build pWBD1.fasta pWBD1
# bowtie2-build pWBDs.fasta pWBDs

echo "Running Bowtie2 alignments..."

# Alignments to WDV-Enk2
bowtie2 -x ${REF_ENK2} ${INPUT_FASTQ_2_TRIMMED} -S rp_010_2-1-trimmed-3-2-ENK2.sam [cite: 16]
bowtie2 -x ${REF_ENK2} ${INPUT_FASTQ_1_TRIMMED} -S rp_010_1-1-trimmed-3-2-2-ENK2.sam [cite: 17]

# Alignments to Phytoplasma plasmid (pWBD1)
bowtie2 -x ${REF_PWBD1} ${INPUT_FASTQ_2_TRIMMED} -S rp_010_2-1-trimmed-3-2-pWBD1.sam [cite: 18]

# Alignments to pWBDs
bowtie2 -x ${REF_PWBDS} ${INPUT_FASTQ_2_TRIMMED} -S rp_010_2-1-trimmed-3-2-pWBDs.sam [cite: 19]
bowtie2 -x ${REF_PWBDS} ${INPUT_FASTQ_1_TRIMMED} -S rp_010_1-1-trimmed-3-2-pWBDs.sam [cite: 20]

# Alignments to ENK1
bowtie2 -x ${REF_ENK1} ${INPUT_FASTQ_2_TRIMMED} -S rp_010_2-1-trimmed-3-2-ENK1.sam [cite: 21]
bowtie2 -x ${REF_ENK1} ${INPUT_FASTQ_1_TRIMMED} -S rp_010_1-1-trimmed-3-2-ENK1.sam [cite: 22]

# Alignments after further trimming (to -trimmed-4.fastq)
bowtie2 -x ${REF_ENK1} ${INPUT_FASTQ_1_TRIMMED_4} -S rp_010_2-1-trimmed-4.sam [cite: 29]
bowtie2 -x ${REF_ENK1} ${INPUT_FASTQ_2_TRIMMED_4} -S rp_010_2-1-trimmed-4.sam [cite: 29]

# Alignments after further trimming (to -tr-6.fastq)
bowtie2 -x ${REF_ENK1} ${INPUT_FASTQ_2_TRIMMED_6} -S rp_010_2-1-tr-6.sam [cite: 34]
# Re-run with -U for unpaired reads (as seen in your log)
bowtie2 -x ${REF_ENK1} -U ${INPUT_FASTQ_2_TRIMMED_6} -S rp_010_2-1-tr-6.2.sam [cite: 38]


echo "Alignments complete. Check SAM files in results/alignment_stats/ (or similar)."

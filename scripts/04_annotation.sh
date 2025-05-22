#!/bin/bash

# Load modules
module load bioinfo-tools
module load snpEff/4.3t # Adjust version as needed

# Define paths and genome (adjust as per your project structure)
MY_SNPEFF_DBS="/home/elhamy/snic2018-8-322/from_pica/private/WDVtrial/snpeff" # Or adjust to your repo structure, e.g., "<span class="math-inline">\(pwd\)/snpeff\_db"
GENOME\="WDV" \# Name for your WDV genome in SnpEff
\# 1\. Create SnpEff database directory and place GenBank file
\# The 'genes\.gbk' file \(your WDV genome GenBank\) should be placed inside the WDV directory\.
echo "Setting up SnpEff database\.\.\."
mkdir \-p "</span>{MY_SNPEFF_DBS}/<span class="math-inline">\{GENOME\}"
\# cp path/to/your/genes\.gbk "</span>{MY_SNPEFF_DBS}/<span class="math-inline">\{GENOME\}/genes\.gbk" \# Copy your GenBank file here
\# 2\. Create SnpEff config file
echo "</span>{GENOME}.genome : <span class="math-inline">\{GENOME\}" \> "</span>{MY_SNPEFF_DBS}/snpEff.config" [cite: 79]

# 3. Build the SnpEff database
echo "Building SnpEff database for ${GENOME}..."
java -jar $SNPEFF_ROOT/snpEff.jar build -genbank -dataDir ${MY_SNPEFF_DBS} -v ${GENOME} [cite: 76, 80]

# 4. Run SnpEff for functional annotation
echo "Running SnpEff for functional annotation..."
INPUT_VCF="/home/elhamy/snic2018-8-322/from_pica/private/WDVtrial/rp_010_1-1-tr-var-final.vcf" # Adjust to your VCF path
OUTPUT_VCF_ANNOTATED="rp_010_1-1-tr-var-final_annotated.vcf"

java -jar <span class="math-inline">SNPEFF\_ROOT/snpEff\.jar eff \-v \-config "</span>{MY_SNPEFF_DBS}/snpEff.config" ${GENOME} ${INPUT_VCF} > ${OUTPUT_VCF_ANNOTATED} [cite: 77]

echo "SnpEff annotation complete. Annotated VCF file generated."

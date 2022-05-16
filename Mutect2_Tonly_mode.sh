#!/bin/bash
#SBATCH -J seba
#SBATCH -N 1
#SBATCH -n 2
#SBATCH -o %x%j.o
#SBATCH -e %x%j.e
#SBATCH -p mrcs
#SBATCH -w Zeta
#tool_path
GATK=/data/MRC1_data4/kysbbubbu/tools/gatk-4.2.1.0
DB=/data/MRC1_data4/kysbbubbu/genomicdb

##OUTPUT
BAM_DIR=./02_BAM
MT_DIR=./04_MT2
ANNO_DIR=./05_Annovar

for T in 1T 2T 3T 4T 5T 2T_2
do
$GATK/gatk --java-options "-Xmx4g" Mutect2 -R $DB/human_g1k_v37.fasta -I $BAM_DIR/$T\_b37.bam --callable-depth 20 --intervals $DB/SureselectV6.list --f1r2-tar-gz $MT_DIR/$T\.tar.gz --germline-resource $DB/af-only-gnomad.raw.sites.b37.vcf.gz -O $MT_DIR/$T\.vcf 
$GATK/gatk --java-options "-Xmx4g" LearnReadOrientationModel -I $MT_DIR/$T\.tar.gz -O $MT_DIR/$T\_cal.tar.gz
$GATK/gatk --java-options "-Xmx4g" FilterMutectCalls -V $MT_DIR/$T\.vcf --ob-priors $MT_DIR/$T\_cal.tar.gz -R $DB/human_g1k_v37.fasta --intervals $DB/SureselectV6.list -O $MT_DIR/$T\_filt.vcf
done

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
FUNCTO=/data/MRC1_data4/kysbbubbu/genomicdb/funcotator/funcotator_dataSources.v1.7.20200521s

##OUTPUT
BAM_DIR=./02_BAM
MT_DIR=./04_MT
ANNO_DIR=./05_Annovar
FUNCO_DIR=./07_FUNCTO

list1="1N 2N 3N 4N 5N 6N 7N 2N"
list2="1T 2T 3T 4T 5T 6T 7T 2T_2"
echo $list1 | sed 's/ /\n/g' > /tmp/h.$$
echo $list2 | sed 's/ /\n/g' > /tmp/i.$$
paste /tmp/h.$$ /tmp/i.$$ | while read N T; do
do
$GATK/gatk --java-options "-Xmx4g" Mutect2 -R $DB/human_g1k_v37.fasta -I $BAM_DIR/$N\_b37.bam -I $BAM_DIR/$T\_b37.bam -normal $N --callable-depth 20 --intervals $DB/SureselectV6.list --f1r2-tar-gz $MT_DIR/$T\.tar.gz --germline-resource $DB/af-only-gnomad.raw.sites.b37.vcf.gz -O $MT_DIR/$T\.vcf 
$GATK/gatk --java-options "-Xmx4g" CalculateContamination -I $MT_DIR/$T\_pileups.table -matched $MT_DIR/$N\_pileups.table -O $MT_DIR/$T\_contamination.table
$GATK/gatk --java-options "-Xmx4g" LearnReadOrientationModel -I $MT_DIR/$T\.tar.gz -O $MT_DIR/$T\_cal.tar.gz
$GATK/gatk --java-options "-Xmx4g" FilterMutectCalls -V $MT_DIR/$T\.vcf --ob-priors $MT_DIR/$T\_cal.tar.gz -R $DB/human_g1k_v37.fasta --intervals $DB/SureselectV6.list -O $MT_DIR/$T\_filt.vcf
awk -F '\t' '{if($7== NULL) print; else if($7 == "FILTER") print ; else if($7 == "PASS") print}' $MT_DIR/$T\_filt.vcf > $MT_DIR/$T\_filt2.vcf
done
rm /tmp/h.$$
rm /tmp/i.$$


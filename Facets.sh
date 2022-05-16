#!/bin/bash
#SBATCH -J FACET
#SBATCH -N 1
#SBATCH -n 8
#SBATCH -o %x.o%j
#SBATCH -e %x.e%j
#SBATCH -p mrcs
#SBATCH -w Zeta
#tool_path
DB=/data/MRC1_data4/kysbbubbu/genomicdb

##OUTPUT
BAM_DIR=./02_BAM
FACET_DIR=./06_FACET
list1="1N 2N 3N 4N 5N 2N"
list2="1T 2T 3T 4T 5T 2N_2"
echo $list1 | sed 's/ /\n/g' > /tmp/a.$$
echo $list2 | sed 's/ /\n/g' > /tmp/b.$$
paste /tmp/a.$$ /tmp/b.$$ | while read item1 item2; do
cnv_facets.R -t $BAM_DIR/$item2\_b37.bam -n $BAM_DIR/$item1\_b37.bam -vcf $DB/00-common_all.vcf.gz -bq 20 -mq 30 -T $DB/SureselectV6.bed --cval 100 1000 -g hg19 -a $DB/Sensus_v92.bed -o $FACET_DIR/$item2
done
rm /tmp/a.$$
rm /tmp/b.$$



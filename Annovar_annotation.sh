#!/bin/bash
#SBATCH -J seba
#SBATCH -N 1
#SBATCH -n 4
#SBATCH -o %x%j.o
#SBATCH -e %x%j.e
#SBATCH -p mrcs
#SBATCH -w Zeta
#tool_path
DB=/data/Delta_data4/kysbbubbu/genomicdb
ANNOVAR=/data/Delta_data4/kysbbubbu/tools/annovar/

##OUTPUT
ANNO_DIR=./05_Annovar
for T in Annovar_tonly2
do
$ANNOVAR/table_annovar.pl $ANNO_DIR/$T\.txt $DB/humandb -buildver hg19 -out $ANNO_DIR/$T -remove -protocol refGene,cytoBand,cosmic95_coding,cosmic95_noncoding,icgc28,exac03,gnomad211_exome,clinvar_20220320,dbnsfp42a,avsnp150 -operation g,r,f,f,f,f,f,f,f,f -nastring . -otherinfo
done

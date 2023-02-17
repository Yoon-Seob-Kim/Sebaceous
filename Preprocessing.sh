#!/bin/bash
#SBATCH -J seba
#SBATCH -N 1
#SBATCH -n 4
#SBATCH -o %x%j.o
#SBATCH -e %x%j.e
#SBATCH -p mrcs
#SBATCH -w Zeta

#tool_path
BWA=/data/Delta_data4/kysbbubbu/tools/bwa-0.7.17
GATK=/data/Delta_data4/kysbbubbu/tools/gatk-4.2.5.0
QUALIMAP=/data/Delta_data4/kysbbubbu/tools/qualimap_v2.2.1
DB=/data/Delta_data4/kysbbubbu/genomicdb
FASTQ_DIR=./

##OUTPUT
FASTQC_DIR=./01_FastQC
BAM_DIR=./02_BAM
BAMQC_DIR=./03_BAMQC
MT_DIR=./04_MT
ANNO_DIR=./05_Annovar
for i in SN03T
do
$GATK/gatk --java-options "-Xmx4g" FastqToSam -SM $i -F1 $FASTQ_DIR/$i\_1.fastq.gz -F2 $FASTQ_DIR/$i\_2.fastq.gz -RG $i -O $i\_unmapped.bam
$BWA/bwa mem -t 8 $DB/human_g1k_v37.fasta $FASTQ_DIR/$i\_1.fastq.gz $FASTQ_DIR/$i\_2.fastq.gz > $i\.sam
$GATK/gatk --java-options "-Xmx4g" MergeBamAlignment -R $DB/human_g1k_v37.fasta -UNMAPPED $i\_unmapped.bam -ALIGNED $i\.sam -O $i\.bam
rm $i\.sam $i\_unmapped.bam
$GATK/gatk --java-options "-Xmx4g" AddOrReplaceReadGroups -I $i\.bam -O $i\_RG.bam -SO coordinate --CREATE_INDEX -ID $i -LB $i -PU $i -PL ILLUMINA -SM $i
rm $i\.bam $i\.bam.bai
$GATK/gatk --java-options "-Xmx4g" MarkDuplicates -I $i\_RG.bam -O $i\.bam -M $i\_dup_metrics.txt
rm $i\_RG.bam $i\_RG.bai $i\_dup_metrics.txt
$GATK/gatk --java-options "-Xmx4g" BaseRecalibrator -R $DB/human_g1k_v37.fasta -I $i\.bam --known-sites $DB/dbsnp_138.b37.vcf --known-sites $DB/1000G_phase1.indels.b37.vcf -O $i\_recal_data.table
$GATK/gatk --java-options "-Xmx4g" ApplyBQSR -R $DB/human_g1k_v37.fasta -I $i\.bam -bqsr $i\_recal_data.table -O $BAM_DIR/$i\_b37.bam
rm $i\.bam $i\.bam.bai $i\_recal_data.table
$GATK/gatk --java-options "-Xmx4g" GetPileupSummaries -R $DB/human_g1k_v37.fasta -I $BAM_DIR/$i\_b37.bam -O $MT_DIR/$i\_pileups.table -V $DB/af-only-gnomad.raw.sites.b37.vcf.gz --intervals $DB/SureselectV5.list
$QUALIMAP/qualimap bamqc -bam $BAM_DIR/$i\_b37.bam -gff $DB/SureselectV5.bed -outdir $BAMQC_DIR/$i -c --java-mem-size=4G
$GATK/gatk --java-options "-Xmx4g" HaplotypeCaller -R $DB/human_g1k_v37.fasta -I $BAM_DIR/$i\_b37.bam --intervals $DB/Sensus_v92_exome.list -ERC GVCF -O $MT_DIR/$i\_germline.vcf.gz
done


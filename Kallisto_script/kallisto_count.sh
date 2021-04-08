#!/bin/bash
# Estimate the abundace of both transcripts and entire genes 
# Build customized reference by concatenating two references 
# 1) standard input - isoforms with exonic sequences 
# 2) entire gene (both exons and introns) as isoforms.
#
# INPUTS: 
# CRAM file, reference FASTA, gene annotation file GTF, output PATH 
#
# OUTPUTS:
# Kallisto outputs => abundance.h5, abundance.tsv, run_info.json 
# a table with each gene's mature mRNA and nascent mRNA abundance 
# 
# create an environment with tools we need
# conda create -n count_reads kallisto samtools bedtools bedops r-essentials r-base bioconductor-biomart
#
unset R_HOME
# get inputs
input_cram=$1
ref=$2
gtf=$3
output=$4 
#
# make a directory to store transcript FASTA and gene FASTA
filename=$(basename -- "$(dirname -- "$input_cram")")
cd $output
if [ ! -d "$filename" ] 
then  
  mkdir $filename
fi
cd $filename
#
# transform cram file into fastq
bamtofastq F=$filename.1.fq.gz F2=$filename.2.fq.gz filename=$input_cram inputformat=cram reference=$ref gz=1
fastq1=$(find ./ -name '*.fq.gz'|head -n 1)
fastq2=$(find ./ -name '*.fq.gz'|tail -n 1)
#
# build a reference with entire gene sequences as isoforms  
# subset only sequences annotated as "gene"
awk '$3 == "gene"' $gtf > ${gtf%.gtf}_gene.gtf
gene_gtf=${gtf%.gtf}_gene.gtf 
# transform gene gtf into a bed file
awk '{ if ($0 ~ "transcript_id") print $0; else print $0" transcript_id "";"; }' $gene_gtf | gtf2bed - > output.bed 
# transform previous bed file into FASTA, this is the reference of pre-mRNA  
bedtools getfasta -fi $ref -bed output.bed -nameOnly -s > gtf2fasta.fa 
#
# transfrom gtf file to transcript FASTA
# this FASTA has transcript sequences, as the reference of mature mRNAs
gffread $gtf -w transcripts.fa -g $ref 
#
# build the final reference
cat gtf2fasta.fa transcripts.fa > gene.fa # concatenate transcript FASTA and gene FASTA 
#
# make a directory to store Kallisto outputs  
if [ ! -d "Kallisto" ] 
then  
  mkdir Kallisto
fi
#
# Run Kallisto 
kallisto index gene.fa -i index.fa # index  
kallisto quant -i index.fa -o ./Kallisto/ $fastq1 $fastq2 # quantify  
#
# clean and sort Kallisto output 
Rscript Transform_Kallisto.R ./Kallisto/abundance.tsv
# output
# kallisto_results.csv => a table with each gene's mature mRNA and nascent mRNA abundance 
#!/bin/bash
# this script runs "htseq-count" to quantify 
# 1) read counts of transcript exons (mature mRNAs) 
# 2) read counts of both exons and introns (a mixture of mature and nascent mRNAs)
#
# INPUTS: 
# CRAM file, reference FASTA file, output PATH 
#
# OUTPUTS:
# mature.txt => a table with counts for mature mRNAs
# mix.txt => a talbe with counts for nascent and matuer mRNAs
# joined_results.csv => joined table with both results
#
# BEFORE RUN:
#create conda environment with tools we need
#conda create -n count_reads htseq r-essentials r-base
#conda activate count_reads #activate this environment 
#
unset R_HOME
# read in inputs
cram=$1
ref=$2
output=$3
#
__dir=$(pwd)
# make a directory w/ sample name to store outputs
cd $output
filename=$(basename -- "$(dirname -- "$cram")") #extract sample names  
if [ ! -d "./$filename" ]  #check if the sample name directory exists
then  
  mkdir $filename  #if not then make a new directory with sample name to store counting results  
fi
#
# read counts w/ htseq-count
# count reads aligning to exons (default)
htseq-count -q -m intersection-strict $cram $ref > ./$filename/mature.txt 
#
# count reads aligning to both introns and exons (set feature type to "gene")  
# htseq-count aligns reads to sequences with annotated feature "gene" in GTF  
htseq-count -q -m intersection-strict -t gene $cram $ref > ./$filename/mix.txt # specified as -t gene  
#
# Rscript that joins two count table   
# table has three columns => "gene_id","mature", "mix"  
#
Rscript $__dir/join_htseq_output.R ./$filename/ 
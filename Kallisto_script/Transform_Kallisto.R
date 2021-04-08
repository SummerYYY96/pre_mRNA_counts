# clean the Kallisto output
# INPUT: 
# abundance.tsv  
#
# OUTPUT:
# a table with each gene's abundance of transcript (mature) and abundance of gene (nascent)  
#
# To get the transcript counts for each gene  
# Assume we have gene_A 
# Gene_A has corresponding transcripts t1, t2, t3   
# number of transcripts of geneA = counts of t1 + counts of t2 + counts of t3.  
#
# target_id in ENST
# need library biomaRt 
suppressMessages(library("biomaRt"))
#
# read in kallisto output 
args <- commandArgs(trailingOnly = TRUE)
tsv_file_path <- args[1]
result <- read.delim(tsv_file_path)
#
#spilt up transcript(mature) abundance and gene(pre) abundance  
ENST <- result[grep("ENST", result$target_id), ]
ENSG <- result[grep("ENSG", result$target_id), ]
#
# get corresponding ensembl gene id for each transcript  
mart <- useMart("ensembl")
ensembl = useDataset("hsapiens_gene_ensembl",mart=mart)
G_list <- getBM(filters = "ensembl_transcript_id", 
                  attributes = c("ensembl_gene_id","ensembl_transcript_id"),
                  values = ENST$target_id, mart = ensembl, useCache = FALSE) 
# 
# calculate mature RNA counts of each gene
joined_ENST <- merge(ENST, G_list, by.x = "target_id", by.y = "ensembl_transcript_id", all = TRUE) #merge 
joined_ENST <- joined_ENST[,c("est_counts", "tpm", "ensembl_gene_id")]
joined_ENST <- aggregate(data=joined_ENST,.~ensembl_gene_id,FUN=sum) # sum up transcript abundance for each gene
print(head(joined_ENST))
colnames(joined_ENST) <- paste0(colnames(joined_ENST),".mature") # add extension to specify columns with mature mRNA counts
output <- merge(ENSG, joined_ENST, by.y = "ensembl_gene_id.mature", by.x = "target_id", all = TRUE)
#
# save output
write.csv(output, file = "./kallisto_results.csv")
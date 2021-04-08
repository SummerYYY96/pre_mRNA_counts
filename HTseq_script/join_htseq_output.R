# take two htseq output and 
# merge two into one table  
#
# INPUTS: 
# mature.txt
# mix.txt
#
# OUTPUT:
# joined_results.csv
#
suppressMessages(library(dplyr))
args <- commandArgs(trailingOnly = TRUE)
#
# take two htseq output
filepath <- args[1]
setwd(filepath)
#
# read data in 
mature <- read.delim(dir(pattern='mature')[1], header = F)
colnames(mature) <- c("gene_id","counts")
mix <- read.delim(dir(pattern='mix')[1], header = F)
colnames(mix) <- c("gene_id","counts")
#
# join two matrices together
joined_original <- left_join(mature, mix, "gene_id")
joined_original <- joined_original[- grep("__", joined_original$gene_id),] # remove special counters from the count table
colnames(joined_original) <- c("gene_id","mature", "mix") 
#
# save outputs as joined_results.  
write.csv(joined_original, file = "./joined_results.csv")
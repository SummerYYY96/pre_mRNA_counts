## Tutorial 
### 1. Set up environment   
#### 1.1 install Anaconda  

The first thing we will be doing is to make sure Anaconda is installed on your machine. Please follow the instructions down below.   
>Install Anaconda https://docs.anaconda.com/anaconda/install/     

If you ever had Anaconda installed, then you already have conda! To check if you have conda, Mac and Linux users can check by running the following command in a terminal.  

type: `which conda`   
expected outcome if conda is installed:  
/Users/$USERNAME/miniconda3/bin/conda  

#### 1.2 Set up channels  

We will have some packages installed from different channels. You can read more about conda channels here https://docs.conda.io/projects/conda/en/latest/user-guide/concepts/channels.html   

We will often be using `bioconda` channel, which holds various bioinformatics packages. https://bioconda.github.io/user/install.html    
Type the following command into terminal to set up channels    
```
conda config --add channels defaults
conda config --add channels bioconda
conda config --add channels conda-forge
```

#### 1.3 create an environment   
We will create an environment for each script available (htseq-count and kallisto). First we create an environment named `htseq_counts` with packages `htseq`, `r-essentials` and `r-base`.  
```
conda create -n htseq_counts htseq r-essentials r-base
```
To enter the environment `htseq_counts` we just set up, we need to execute:  
```
conda activate htseq_counts
```  
To exit the environment we are currently in, run:  
```
conda deactivate   
```  
Set up an environment for Kallisto run   
```
conda create -n kallisto_count kallisto samtools bedtools bedops r-essentials r-base bioconductor-biomart
```
Similarly, to enter the environment `kallisto_count`, we need to execute:  
```
conda activate htseq_counts
```  
To exit the environment we are currently in, simply run:  
```
conda deactivate   
```  
### 2. Run scripts  
#### 2.1 Provide input data      
Both scripts assume the user has following input files available:  

1. A sorted CRAM file   
2. The reference (FASTA) that the sequence data is aligned to  
3. A gene annotation file (GTF file)   

#### 2.2 Run the htseq_count script   
##### 2.2.1 How to run the script   
First, activate the conda environment we set up earlier:  
```
conda activate htseq_counts
```
The script `htseq_count.sh` requires file path to the CRAM file, the reference and the desired output directory, e.g.  
```
htseq_count.sh <sample.cram> <reference.fa> <output_dir>  
```  
**Note**: if you are first time running the script, type following in the terminal before running it `chmod +x htseq_count.sh`   

##### 2.2.2 Expected output   
In the output directory, output files include two text files and a csv file under the directory named after the cram file name.   

- `All_Results_mature.txt` contains gene IDs and the read counts of mature mRNAs
- `All_Results_mix.txt` contains gene IDs and the read counts of a mixture of pre mRNAs and mature mRNAs
- `joined_results.csv` is a dataset that merges two results together for further downstream analysis
  
##### 2.2.3 A brief walkthrough of the counting    
We utilized `intersection-strict` mode in `htseq-count`. In this case, only reads completely and uniquely align to the transcript exons is counted. This output is the read count for spliced mRNAs.     

When counting reads toward the whole gene (both exons and introns), we specified feature type as "gene". Then `htseq-count` would only select "gene" feature from the GTF file, and count reads that uniquely align to the whole gene sequence. In this case, we get counts for both nascent and mature mRNAs because we couldn't distinguish reads from mature mRNAs exonic regions and pre mRNAs exonic regions. This output is the count table for a mixture of both mRNAs.         

The following figure illustrates how the overlap resolution modes in `htseq-count` work; notice how `htseq-count` handles gaps between exons:   

![alt text](https://htseq.readthedocs.io/en/release_0.11.1/_images/count_modes.png)  

#### 2.3 Run the kallisto_count script   
##### 2.3.1 How to run the script   
First, activate the conda environment we set up earlier:  
```
conda activate kallisto_count
```
The script `kallisto_count.sh` requires file path to the CRAM file, the reference, the gene annotation, and the desired output directory, e.g.  
```
kallisto_count.sh <sample.cram> <reference.fa> <annotation.gtf> <output_dir>  
```  

##### 2.3.2 Expected output   
In the directory named after the cram file name, output files are under the directory `Kallisto`. Kallisto produces three output files:  

- `abundances.h5` is an HDF5 binary file containing run info, abundance estimates
- `abundance.tsv` contains the estimated counts, TPM, and effective length for each transcript and gene 
- `run_info.json`, a json file containing info about the run  
- `kallisto_results`, a data table with each gene's abundance of mature mRNAs and abundance of nascent mRNAs
 
##### 2.3.3 A brief walkthrough of the thought process     
To estimate the abundance of both transcripts and entire genes, we feed Kallisto a customized reference by concatenating two references 1) standard input - isoforms with exonic sequences 2) entire gene (both exons and introns) as isoforms.   

Kallisto will estimate the abundance of each transcript and entire gene. Then we calculate the transcript abundance of each gene by summing up all estimated counts of that gene's transcripts. The summed transcript abundance is the mature mRNA abundance. The abundance of the entire gene is the nascent mRNA abundance.       

### 3. Some notes on this pipeline   
Both counting schemes have a good concordance, especially in genes with a significant difference between mature mRNA and pre-mRNA.  

### References   
[1] Simon Anders, Paul Theodor Pyl, Wolfgang Huber HTSeq — A Python framework to work with high-throughput sequencing data, Bioinformatics (2014), in print, online at doi:10.1093/bioinformatics/btu638   
[2] Bray, N. L., Pimentel, H., Melsted, P. & Pachter, L. Near-optimal probabilistic RNA-seq quantification, Nature Biotechnology 34, 525-527(2016), doi:10.1038/nbt.3519   

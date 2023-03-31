# Title: Metagenomics with phyloseq in R
# Author: Heidi Steiner
# Date: 2023-04-06
# Description: Summarize microbiomes with phyloseq

### install packages
devtools::install_github("twbattaglia/MicrobeDS")
devtools::install_github("joey711/phyloseq")

### library
# library(metaphlanr) # for parsing taxonomic data
library(MicrobeDS) # 
# library(microbiome) # transforming phyloseq data
library(phyloseq) # for metagenomic analyses
# library(scales) # formatting numeric output
library(tidyverse) # read data
# library(vegan) # alpha div

### pull RISK_CCFA data from MicrobeDS
### doi: 10.1016/j.chom.2014.02.005
data('RISK_CCFA')

### save data as objects
outcome <- sample_data(RISK_CCFA)
otu <- otu_table(RISK_CCFA)
taxa <- tax_table(RISK_CCFA)

physeq <- phyloseq(otu, taxa)
plot_bar(physeq, fill = 'Family')


# Title: Metagenomics with phyloseq in R
# Author: Heidi Steiner
# Date: 2023-04-06
# Description: Summarize microbiomes with phyloseq

### install packages
devtools::install_github("twbattaglia/MicrobeDS")
devtools::install_github("joey711/phyloseq")

### library
library(MicrobeDS) # 
library(phyloseq) # for metagenomic analyses
library(tidyverse) # read data

### pull RISK_CCFA data from MicrobeDS
### doi: 10.1016/j.chom.2014.02.005
data('RISK_CCFA')

### save data as objects
outcome <- sample_data(RISK_CCFA)
otu <- otu_table(RISK_CCFA)
taxa <- tax_table(RISK_CCFA)

### inspect data objects
colnames(sample_data(outcome))
otu_table(otu)[1:5, 1:5]
tax_table(taxa)[1:5, 1:4]

### create phyloseq object
physeq <- phyloseq(otu, taxa, outcome)

ntaxa(physeq)
nsamples(physeq)
sample_names(physeq)[1:10]
rank_names(physeq)

### filter data
physeqRel  = transform_sample_counts(physeq, function(x) x / sum(x) ) # relative counts
physeqRelFilter = filter_taxa(physeqRel, function(x) mean(x) > 1e-3, TRUE) # only OTUs greater than 10^-5
ntaxa(physeqRelFilter)

### subset data
physeqRelFilterBac = subset_taxa(physeqRelFilter, Phylum=="Bacteroidetes")
ntaxa(physeqRelFilterBac)

physeqRelFilterBacCD = physeqRelFilterBac |> 
  subset_samples(sample_type == "stool" &  # select only stool samples
                   diagnosis == "CD" & # from patients with crohn's
                   smoking %in% c("Current", "Former")) # who have history of smoking

### visualize data
plot_bar(physeqRelFilterBacCD, fill = "Genus") # relative abundance of OTUs color by Genus
plot_bar(physeqRelFilterBacCD, "Family", fill="Genus", facet_grid=~steroids) # use visualizations to summarize differences 

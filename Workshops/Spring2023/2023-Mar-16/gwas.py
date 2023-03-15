#### load python packages 
import hail as hl

#### initiate hail 
hl.init()
hl.plot.output_notebook()

#### load hail libraries
import hail as hl
from hail.plot import show
from pprint import pprint
# from bokeh.io import save # To save your plots! 

#### Download public 1000 Genomes data as example
hl.utils.get_1kg('data/')

#### read in example genomic data
mt = hl.read_matrix_table('data/1kg.mt')
mt.describe()

##INFO=<ID=NS,Number=1,Type=Integer,Description="Number of Samples With Data"> 
##INFO=<ID=DP,Number=1,Type=Integer,Description="Total Depth"> 
##INFO=<ID=AF,Number=A,Type=Float,Description="Allele Frequency"> 
##INFO=<ID=AA,Number=1,Type=String,Description="Ancestral Allele"> 
##INFO=<ID=DB,Number=0,Type=Flag,Description="dbSNP membership, build 129"> 
##INFO=<ID=H2,Number=0,Type=Flag,Description="HapMap2 membership"> 
##FILTER=<ID=q10,Description="Quality below 10"> 
##FILTER=<ID=s50,Description="Less than 50% of samples have data"> 
##FORMAT=<ID=GT,Number=1,Type=String,Description="Genotype"> 
##FORMAT=<ID=GQ,Number=1,Type=Integer,Description="Genotype Quality"> 
##FORMAT=<ID=DP,Number=1,Type=Integer,Description="Read Depth"> 
##FORMAT=<ID=HQ,Number=2,Type=Integer,Description="Haplotype Quality">

#### view rows
mt.rows().select().show(5) # leaving slect() blank selects the "keys"

#### read in example phenotype data
pheno = (hl.import_table('data/1kg_annotations.txt', impute=True)
         .key_by('Sample'))
         
pheno.describe()

### MatrixTable Anatomy
### Recall that Table has two kinds of fields:
## 1. global fields
## 2. row fields
#### MatrixTable has four kinds of fields:
## 1. global fields
## 2. row fields
## 3. column fields
## 4. entry fields

#### Annotate genoypte data with phenotypes per subject
mt = mt.annotate_cols(pheno = table[mt.s])
mt.col.describe()


#### Summary Statistics of Outcome Variable
pprint(mt.aggregate_cols(hl.agg.stats(mt.pheno.CaffeineConsumption)))

#### Perform Quality Control tests on each subject
mt = hl.sample_qc(mt)
mt.col.describe()

#### Example visualizing QC metrics
p = hl.plot.histogram(mt.sample_qc.call_rate, range=(.88,1), legend='Call Rate')
show(p)

#### Subset data by random QC cutoffs
mt = mt.filter_cols((mt.sample_qc.dp_stats.mean >= 4) & (mt.sample_qc.call_rate >= 0.97))
print('After filter, %d/284 samples remain.' % mt.count_cols())

#### Qualitry control steps per variants
mt = hl.variant_qc(mt)
mt.row.describe()

#### Subset by QC cutoffs
mt = mt.filter_rows(mt.variant_qc.AF[1] > 0.01)
mt = mt.filter_rows(mt.variant_qc.p_value_hwe > 1e-6)

#### Summarize
print('Samples: %d  Variants: %d' % (mt.count_cols(), mt.count_rows()))

#### GWAS
gwas = hl.linear_regression_rows(y=mt.pheno.CaffeineConsumption,
                                 x=mt.GT.n_alt_alleles(),
                                 covariates=[1.0])
gwas.row.describe()

#### plot results
p = hl.plot.manhattan(gwas.p_value)
show(p)

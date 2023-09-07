# LibraryQuant
Calculting undiluted library concentrations from qPCR results using NEBNext® Library Quant Kit for Illumina® (E7630) with two dilution series.
Data analysis per https://www.neb.com/protocols/2015/05/14/data-analysis-e7630

## Getting Started
You will need a qPCR result table that's removed of obvious outliers among the technical replicates, and the NTC samples (after confirming that they have high Ct or Cq numbers).

### Prerequisites
R with the following libraries installed:  data.table, ggplot2, ggpmisc, scales, dplyr, reshape2

qPCR Ct/Cq table: 4 columns. The first column "SampleType" contains factors of either "library" or "STN" (standards); the second column "Sample" contains the sample names (e.g. "library1", "library2", "STN1", "STN2"); the third column "Dilution" contains the dilution factor of the particular well (numeric, e.g. 1000, 10000, 100000); the fourth column "CT" contains Ct or Cq numbers from the qPCR (numeric). See the Example_input folder for an example table.
Note the script expect most libraries have results for two dilutions. It still works when some of the libraries have results for only 1 dilution, but it won't work if all the libraries are tested at only one dilution level.

```
SampleType  Sample  Dilution  CT
STN  STN2 1 19
library lib_1 100000  17
```


### Usage
Run this R script with your qPCR Ct/Cq table and average library size (numeric) as parameters

```
Rscript LibraryQuant_source.R YOUR_QPCR_CT.tsv YOUR_LIBRARY_SIZE NUM_STNs
```
For example:
```
Rscript LibraryQuant_source.R Example_Input/libCT_clean_6.txt 250 6
```

### Output
A file named standard_curve.pdf with the plot for the standard curve, and a file named Avg.Undiluted.Conc.csv. Explanation of the columns of the latter file:
nM_undil_sizeadj_<i>k : library concentration in nM after size adjustment calculated from <i>k dilution.
nM_undil_sizeadj.mean: mean library concentration in nM after size adjustment calculated from the two dilutions
nM_diff_btw_dilutions: the differences in library concentration in nM after size adjustment calculated from the two dilutions
frac_diff: the fraction of the difference relative to the mean library concentration

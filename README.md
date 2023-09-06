# LibraryQuant
Calculting undiluted library concentrations from qPCR results using NEBNext® Library Quant Kit for Illumina® (E7630) with two dilution series.
Data analysis per https://www.neb.com/protocols/2015/05/14/data-analysis-e7630

## Getting Started
You will need a qPCR result table that's removed of obvious outliers among the technical replicates, and the NTC samples (after confirming that they have high Ct or Cq numbers).

### Prerequisites
R with the following libraries installed:  data.table, ggplot2, ggpmisc, scales, dplyr

qPCR Ct/Cq table: 4 columns. The first column "SampleType" contains factors of either "library" or "STN" (standards); the second column "Sample" contains the sample names (e.g. "library1", "library2", "STN1", "STN2"); the third column "Dilution" contains the dilution factor of the particular well (numeric, e.g. 1000, 10000, 100000); the fourth column "CT" contains Ct or Cq numbers from the qPCR (numeric). See the Example_input folder for an example table.

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

### Output
A file named standard_curve.pdf with the plot for the standard curve, and a file named Avg.Undiluted.Conc.tsv with the size adjusted average concentration in nM for each of the tesed libraries, as well as the difference between the conctrations caculated from the two dilutions.

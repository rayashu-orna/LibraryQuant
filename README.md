# LibraryQuant
Calculting undiluted library concentrations from qPCR results using NEBNext® Library Quant Kit for Illumina® (E7630) with two dilution series.
Data analysis per https://www.neb.com/protocols/2015/05/14/data-analysis-e7630

## Getting Started
You will need a qPCR result table that's removed of obvious outliers among the technical replicates, and the NTC samples (after confirming that they have high Ct or Cq numbers).

### Prerequisites
R with the following libraries installed:  data.table, ggplot2, ggpmisc, scales, dplyr, reshape2

qPCR Ct/Cq table, tab delimited: 4 columns. 
- `SampleType` contains factors of either "library" or "STN" (standards)
- `Sample` contains the sample names (e.g. "library1", "library2", "STN1", "STN2")
- `Dilution` contains the dilution factor of the particular well (numeric, e.g. 1000, 10000 or 100000 for libraries, 1 for standards);
-  `CT` contains Ct or Cq numbers from the qPCR (numeric).

See the Example_input folder for some example tables.

```
SampleType  Sample  Dilution  CT
STN  STN2 1 19
library lib_1 100000  17
```
Note the script expects libraries to be tested at two dilutions. It still works when some of the libraries have results for only 1 of the dilutions, but it won't work if all the libraries have only one dilution level.

### Usage
In the same directory of `LibraryQuant_source.R`, run this R script with your qPCR Ct/Cq table `YOUR_QPCR_CT.tsv`, average library size in bp (numeric) `YOUR_LIBRARY_SIZE`, and number of standards you used (4 or 6) `NUM_STNs` as parameters

```
Rscript LibraryQuant_source.R path/to/YOUR_QPCR_CT.tsv YOUR_LIBRARY_SIZE NUM_STNs
```
For example:
```
Rscript LibraryQuant_source.R Example_Input/libCT_clean_6.txt 250 6
```

### Output
A file named standard_curve.pdf with the plot for the standard curve, and a file named Avg.Undiluted.Conc.csv. Explanation of the columns of the latter file:
- `nM_undil_sizeadj_<x>k` library concentration in nM after size adjustment calculated from `<x>k` dilution.
- `nM_undil_sizeadj.mean` mean library concentration in nM after size adjustment calculated from the two dilutions
- `nM_diff_btw_dilutions` the differences in library concentration in nM after size adjustment calculated from the two dilutions
- `frac_diff` the fraction of the difference relative to the mean library concentration

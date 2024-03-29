#!/usr/bin/env Rscript



args <- commandArgs(trailingOnly=TRUE)

# read in qPCR Ct values
Ct <- data.table::fread(args[1])
# Ct <- data.table::fread("Example_Input/libCT_clean_4stn.tsv")

# library size
lib_size <- as.numeric(args[2])
# lib_size <- 250

# stn table option
Num_stn <- as.numeric(args[3])
# Num_stn <- 4


# make standard curve
Stn <- Ct[Ct$SampleType == "STN",]

if(!(Num_stn %in% c(4, 6))) {
  print("please make sure your NUM_STNs is either 4 or 6")
} else {
  Stn_concentration <- data.table::fread(paste0("STNs", Num_stn, ".txt"))
}
Stn <- merge(Stn, Stn_concentration, "Sample")
Stn$Log10pM <- log10(Stn$pM)

Stn_fit <- lm(CT ~ Log10pM, data = Stn)
E <- scales::percent_format(accuracy = 0.01)(10^(-1/Stn_fit$coefficients[2]) -1)

library(ggplot2)
library(ggpmisc)

p <- ggplot(Stn, aes(Log10pM, CT)) +
      geom_smooth(method = "lm", formula = y~x, se = FALSE, colour = "#de3259", size = 0.75) +
      geom_point(shape = 21, colour = "#402d84", size = 1.5, stroke = 0.75) +
      stat_poly_eq(formula = y ~ x, 
                   aes(label = paste(stat(eq.label), stat(rr.label), sep = "*\", \"*")), 
                   parse = TRUE,
                   coef.digits = 4,
                   rr.digits = 5,
                   label.x = "right",
                   size = 2) +
      annotate("text", lab = paste("Efficiency = ", E), 
               x = max(Stn$Log10pM), 
               y = max(Stn$CT) - 1.5,
               hjust = "inward",
               size = 2)

pdf("standard_curve.pdf", height = 1.8, width = 2.5)
  theme_set(theme_bw(base_size = 6))
  print(p)
dev.off()


# calculate concentrations of test libraries
Ct_lib <- Ct[Ct$SampleType == "library",]
Ct_lib$pM  <- 10^((Ct_lib$CT-Stn_fit$coefficients[1])/Stn_fit$coefficients[2])
Ct_lib$nM_undiluted <- Ct_lib$pM * Ct_lib$Dilution / 1000
Ct_lib$nM_undil_sizeadj <- Ct_lib$nM_undiluted * 399 / lib_size


library(dplyr)
Ct_lib %>%
  group_by(Sample, Dilution) %>%
  summarize(nM_undil_sizeadj.mean = mean(nM_undil_sizeadj)) -> Ct_lib 

Ct_lib <- reshape2::dcast(Ct_lib, Sample ~ Dilution, value.var = "nM_undil_sizeadj.mean")
colnames(Ct_lib)[2:3] <- paste("nM_undil_sizeadj", paste0(as.numeric(colnames(Ct_lib)[2:3])/1000, "k"), sep="_")
Ct_lib$nM_undil_sizeadj.mean <- apply(Ct_lib[,2:3], 1, function(x) mean(x, na.rm = T))
Ct_lib$nM_diff_btw_dilutions <- apply(Ct_lib[,2:3], 1, function(x) abs(diff(x)))
Ct_lib$frac_diff <- Ct_lib$nM_diff_btw_dilutions / Ct_lib$nM_undil_sizeadj.mean

Ct_lib[,2:ncol(Ct_lib)] <- round(Ct_lib[,2:ncol(Ct_lib)], digits = 3)

write.csv(Ct_lib, "Avg.Undiluted.Conc.csv", quote = F, row.names = F)

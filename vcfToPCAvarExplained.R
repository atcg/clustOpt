#!/usr/bin/env Rscript

# Load SNPRelate
suppressPackageStartupMessages(library(SNPRelate))

### Make sure that there is exactly one flag--the VCF file input list
args = commandArgs(trailingOnly=TRUE)
if (length(args)!=2) {
  stop("Exactly two arguments must be supplied (<vcf file list> and <numPCsToSum>).n", call.=FALSE)
}

### Put the VCF filenames into a vector
vcfFiles <- scan(args[1], what = character(), quiet=T)

for (i in 1:length(vcfFiles)) {
    gdsOut <- paste(gsub(".vcf","", vcfFiles[i], fixed=T), '.pcaVar.gds', sep="")
    snpgdsVCF2GDS(vcfFiles[i], gdsOut, verbose=F)
    genofile <- snpgdsOpen(gdsOut)
    pcaz <- snpgdsPCA(genofile, num.thread=2, verbose=F)
    varExplained <- sum(pcaz$varprop[1:args[2]])
    cat("Variance explained by first ", args[2], " PCs for ", vcfFiles[i], ": ", varExplained, "\n", sep="")
    file.remove(gdsOut)
}

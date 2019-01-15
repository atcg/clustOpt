#!/usr/bin/env Rscript

library(SNPRelate)
library(pheatmap)
library(grImport2)
library(dendextend)

### Make sure that there is exactly one flag--the VCF file input list
args = commandArgs(trailingOnly=TRUE)
if (length(args)!=1) {
  stop("Exactly one argument must be supplied (<vcf file list>).n", call.=FALSE)
}

### Get and print a random seed for SNPRelate clustering
randomSeed <- sample(1:100000000, 1)
set.seed(randomSeed)
paste("Random seed for snpgdsHCluster = ", randomSeed, sep="")

### Core functions
makeMatrix <- function(vcfFilename, printStats = 0) {
    intermediateFileName <- paste(gsub(".vcf","", vcfFilename, fixed=T), '_missHM012.missingness', sep="")
    missInter <- read.csv(intermediateFileName, sep="\t", header=T)

    interMatrix <- matrix(nrow=length(unique(missInter$Sample1)), ncol=length(unique(missInter$Sample1)))
    interMatrix[lower.tri(interMatrix, diag=T)] <- (missInter$oneMiss / (missInter$oneMiss + missInter$neitherMiss))
    colnames(interMatrix) <- unique(missInter$Sample1)
    rownames(interMatrix) <- unique(missInter$Sample2)
    interMatrix[upper.tri(interMatrix, diag=F)] <- t(interMatrix)[upper.tri(interMatrix, diag=F)]
    
    if (printStats == 1) {
        minMissingness <- min(interMatrix, na.rm=T)
        maxMissingness <- max(interMatrix, na.rm=T)
        cat(paste("Minimum pairwise missingness for ", vcfFilename, ": ", minMissingness, sep=""), "\n")
        cat(paste("Maximum pairwise missingness for ", vcfFilename, ": ", maxMissingness, sep=""), "\n")
    }
    return(interMatrix)
}

makeVectorHeatmap <- function(missingnessMatrix, dendrogramz, name) {
    # Make the heat map SVG
    heatmapFile <- paste(name, ".heatmap.svg", sep = "")
    svg(heatmapFile, height=4, width=4.44)
    heatmapReordered <- missingnessMatrix[labels(dendrogramz), labels(dendrogramz)]
    pheatmap(heatmapReordered, breaks=mat_breaks, cluster_rows=F, cluster_cols=F, show_rownames=F, show_colnames=F, border_color = F)
    dev.off()

    # Make the dendrogram SVGs
    dendro1 <- paste(name, ".vDendro.svg", sep="")
    dendro2 <- paste(name, ".hDendro.svg", sep="")
    svg(dendro1, height=4.33, width=.6)
    par(mar=c(0,0,0,0), mgp=c(0,0,0))
    plot(rev(dendrogramz), type="rectangle", horiz = T, leaflab = "none", xaxt="n", yaxt="n")
    dev.off()

    svg(dendro2, height=.6, width=4.33)
    par(mar=c(0,0,0,0), mgp=c(0,0,0))
    plot(dendrogramz, type="rectangle", horiz = F, leaflab = "none", xaxt="n", yaxt="n")
    dev.off()

    dendroSVG <- readPicture(file = dendro1)
    dendroBsvg <- readPicture(file = dendro2)
    heatmapSVG <- readPicture(heatmapFile)
    outputname <- paste(name, ".pdf", sep="")
    pdf(outputname, width=10,height=10)
    plot(1, bty="n", type="n", xlab="", ylab="", xlim=c(0, 10), ylim=c(0, 9), xaxt="n", yaxt="n")
    grid.picture(heatmapSVG, x = 5.4, y=4.85, hjust="centre", vjust="centre", width=6.66, height=6, default.units="in")
    grid.picture(dendroSVG, x=2.11, y=4.85, height=6.26, width=.75, default.units="in", distort=T)
    grid.picture(dendroBsvg, x=5.11, y=7.84, height=.75, width=6.25, default.units="in", distort=T)
    
    text(x=5.11, y=9, cex=2, labels = name)
    dev.off()
    
    

    # Delete intermediate files
    unlink(x = c(heatmapFile, dendro1, dendro2))
}


### Put the VCF filenames into a vector
vcfFiles <- scan(args[1], what = character())

### We need to define the quantile breaks across the collection of VCF files, so that
### they all use the same informative color scale for missingness. 
### Read in the first matrix,then rbind all subsequent matrices to the first matrix. 
### Then we'll get the breaks from superMatrix
firstFileName <- paste(gsub(".vcf","", vcfFiles[1], fixed=T), '_missHM012.missingness', sep="")
missFirst <- read.csv(firstFileName, sep="\t", header=T)

superMatrix <- matrix(nrow=length(unique(missFirst$Sample1)), ncol=length(unique(missFirst$Sample1)))
superMatrix[lower.tri(superMatrix, diag=T)] <- (missFirst$oneMiss / (missFirst$oneMiss + missFirst$neitherMiss))
colnames(superMatrix) <- unique(missFirst$Sample1)
rownames(superMatrix) <- unique(missFirst$Sample2)
superMatrix[upper.tri(superMatrix, diag=F)] <- t(superMatrix)[upper.tri(superMatrix, diag=F)]

if (length(vcfFiles) > 1) {
    for (i in 2:length(vcfFiles)) {
        matrixForBinding <- makeMatrix(vcfFiles[i], printStats = 0)

        # Make sure that the full and intermediate matrices line up
        if (!all.equal(colnames(matrixForBinding), colnames(superMatrix))) {
            stop("Col names don't match for ", args[1], " and ", args[i], ": Exiting now", call.=TRUE)
        }

        # Append the intermediate matrix to the full matrix
        superMatrix <- rbind(superMatrix, matrixForBinding)
    }
} else {
    # Here we have only a single VCF file, which is perfectly fine. We actually don't 
    # need to do anything in this case.
}

minMissingness <- min(superMatrix, na.rm=T)
maxMissingness <- max(superMatrix, na.rm=T)
paste("Minimum pairwise missingness across all VCFs (lower legend boundary): ", minMissingness, sep="")
paste("Maximum pairwise missingness across all VCFs (upper legend boundary): ", maxMissingness, sep="")


### Infer the quantile breaks from superMatrix:
quantile_breaks <- function(xs, n = 100) {
    breaks <- quantile(xs, probs = seq(0, 1, length.out = n), na.rm = T)
    breaks[!duplicated(breaks)]
}
mat_breaks <- quantile_breaks(superMatrix, n = 100)

### Now make the heat maps for each threshold 
for (i in 1:length(vcfFiles)) {
    # Make and load the GDS file:
    gdsOut <- paste(gsub(".vcf","", vcfFiles[i], fixed=T), '_missHM012.gds', sep="")

    snpgdsVCF2GDS(vcfFiles[i], gdsOut)

    gdsInter <- snpgdsOpen(gdsOut)
    # Compute the dendrogram:
    ibsInter <- snpgdsHCluster(snpgdsIBS(gdsInter, num.thread=2))

    # First make the matrix
    missingMatrix <- makeMatrix(vcfFiles[i], printStats = 1)
    heatmapFile = paste(gsub(".vcf","", vcfFiles[i], fixed=T), '.heatmap', sep="")
    makeVectorHeatmap(missingMatrix, ibsInter$dendrogram, heatmapFile)
    snpgdsClose(gdsInter)
    file.remove(gdsOut)
}

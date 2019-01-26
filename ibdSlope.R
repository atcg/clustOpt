suppressPackageStartupMessages(library(geosphere))
suppressPackageStartupMessages(library(SNPRelate))

### Make sure that there are exactly two flags--the VCF file input list [1] and the latlong file [2]
args = commandArgs(trailingOnly=TRUE)
if (length(args)!=2) {
  stop("Exactly two arguments must be supplied (<vcf file> and <latLongFile>).n", call.=FALSE)
}

# Pull in the VCF filenames
vcfFiles <- scan(args[1], what = character(), quiet=T)

# Set up the geographic distance matrix:
latLongFile <- read.csv(args[2], sep="\t", header=T)
geoDistMatrix <- matrix(nrow=length(latLongFile$Sample), ncol=length(latLongFile$Sample))
rownames(geoDistMatrix) <- latLongFile$Sample
colnames(geoDistMatrix) <- latLongFile$Sample

# Calculate the pairwise geographic distance between each pair of points, in km:
for (i in 1:length(latLongFile$Sample)) {
    for (j in 1:length(latLongFile$Sample)) {
        geoDistMatrix[i,j] <- distm(c(latLongFile$Long[i], latLongFile$Lat[i]), c(latLongFile$Long[j], latLongFile$Lat[j]), fun = distHaversine) / 1000
    }
}

for (i in 1:length(vcfFiles)) {
    gdsOut <- paste(gsub(".vcf","", vcfFiles[i], fixed=T), '.pcaVar.gds', sep="")
    snpgdsVCF2GDS(vcfFiles[i], gdsOut, verbose=F)
    genofile <- snpgdsOpen(gdsOut)
    ibsMat <- snpgdsIBS(genofile, num.thread=2, verbose=F)

#    cat(head(rownames(geoDistMatrix)))
#    cat(head(ibsMat$sample.id))
#    cat(match(rownames(geoDistMatrix), ibsMat$sample.id), "\n")


    # Rearrange IBS matrix to the same order as geoDistMatrix
    ibsMatRearranged <- ibsMat$ibs[match(rownames(geoDistMatrix), ibsMat$sample.id), match(rownames(geoDistMatrix), ibsMat$sample.id)]

    slopeToReport <- lm(100-ibsMatRearranged[lower.tri(ibsMatRearranged, diag=F)] ~ geoDistMatrix[lower.tri(geoDistMatrix, diag=F)])$coefficients[2]
    cat("IBD slope for ", vcfFiles[i], ": ", 100 * 100 * slopeToReport, "% increased SNP divergence per 100km\n", sep="")

    snpgdsClose(genofile)    
    file.remove(gdsOut)
}

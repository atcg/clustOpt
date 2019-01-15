library(geosphere)

### Make sure that there is exactly one flag--the VCF file input list
args = commandArgs(trailingOnly=TRUE)
if (length(args)!=2) {
  stop("Exactly two arguments must be supplied (<vcf file> and <latLongFile>).n", call.=FALSE)
}


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



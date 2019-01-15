library(geosphere)



# Set up the geographic distance matrix:
latLongFile <- read.csv("latLongFile.tsv", sep="\t", header=T)
geoDistMatrix <- matrix(nrow=length(latLongFile$Sample), ncol=length(latLongFile$Sample))
rownames(geoDistMatrix) <- latLongFile$Sample
colnames(geoDistMatrix) <- latLongFile$Sample

# Calculate the pairwise geographic distance between each pair of points, in km:
for (i in 1:length(latLongFile$Sample)) {
    for (j in 1:length(latLongFile$Sample)) {
        geoDistMatrix[i,j] <- distm(c(latLongFile$Long[i], latLongFile$Lat[i]), c(latLongFile$Long[j], latLongFile$Lat[j]), fun = distHaversine) / 1000
    }
}



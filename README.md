# clustOpt

## Dependencies ##

vcftools must be installed and in the $PATH (i.e. you must be able to call vcftools from the command line by simply typing vcftools). In addition,
the following R packages must be installed:

  1) SNPRelate (http://www.bioconductor.org/packages/release/bioc/html/SNPRelate.html)
  2) pheatmap
  3) geosphere (only needed for running vcfToIBDslope.pl)
  4) grImport2
  5) dendextend
  6) ape (only needed if analyzing RAxML bootstrap values)
  7) phangorn (only needed if analyzing RAxML bootstrap values)

## Installation ##
After the dependencies listed above are installed, all that is needed is to download the scripts in the gitHub repository:

`git clone https://github.com/atcg/clustOpt.git`

This will download everything to a folder called clustOpt/. Scripts can then be run from anywhere by giving the full path to clustOpt/.


## Missingness heat maps ##
To calculate correlations between missingness and relatedness and generate missingness heatmaps that are clustered by genetic relatedness, use the following command:

`perl clustOpt/vcfMissingness.pl --vcflist <vcfListFile>`

Here, vcfListFile is a file with the paths to all VCF files you want to analyze (one per line).

This script does several things, including:

  1) Generates 012 format files from each of the VCF files using vcftools
  2) Calculates all pairwise missingness values from the 012 files using the included script resources/pairwiseMissingnessFrom012.pl
  3) Calculates the Pearson's correlation coefficients between data missingness and genetic relatedness
  4) Generates a color scale that is maximally informative with respect to the data and that is consistent across all VCFs for comparability
  5) Calculates SNP identity by state and clusters samples based on relatedness
  6) Draws heatmaps (one PDF per input VCF) of samples clustered by relatedness where the values indicate pairwise genotype missingness among samples

Specifically, the script vcfToMissHM.pl can be used to generate heatmaps of pairwise missingness that are clustered by genetic similarity similar to Figure 4. The script missVsGenDist.pl can be used to calculate pairwise missingness correlations as a function of genetic distance. For population genomic studies where isolation by distance is likely to play a role in the partitioning of genetic variation, vcfToIBDslope.pl can be used to generate figures similar to Figures 5B for a collection of clustering thresholds. And vcfToPCAvarExplained.pl can be used to calculate the cumulative variance explained by the most important principal components starting from a collection of VCF files. 

## Isolation by distance slopes ##
To calculate the isolation by distance slopes for different clustering thresholds, use the following command:

`Rscript ibdSlope.R  <vcfListFile> <latLongFile>

Here, vcfListFile is a file with the paths to all VCF files you want to analyze (one per line), and latLongFile is a tab-delimited file with the following format:
```
Sample  Lat Long
samp1   34.2134 -122.5731
samp2   33.4421 -121.9874
...
sampN   36.1112 -122.0012
```

The names in the Sample column must match the names in the VCF file exactly (they do not need to be in the same order). Lat/Longs must be in decimal degrees.

The IBD slopes are output to STDOUT, and can then be gathered and plotted in e.g. R.

## Cumulative variance explained by first N PCs ##
To calculate the summed variance explained by the first N principal components for a group of VCF files, use the following command:
`Rscript clustOpt/vcfToPCAvarExplained.R <vcfListFile> N`

Here, vcfListFile is a file with the paths to all VCF files you want to analyze (one per line). N is an integer value that denotes how many PCs to sum
over (for instance, if N=4 then this script will return the cumulative variance explained by PCs 1, 2, 3, and 4). The summed values are printed to STDOUT
and can be plotted using e.g. R.


## Citation ##
Please cite the following papers and R packages when using the scripts below:

For vcfMissingness.pl:
  * Xiuwen Zheng, David Levine, Jess Shen, Stephanie M. Gogarten, Cathy Laurie, Bruce S. Weir. A High-performance Computing Toolset for Relatedness and Principal Component Analysis of SNP Data. Bioinformatics 2012; doi:
10.1093/bioinformatics/bts606
  * Tal Galili (2015). dendextend: an R package for visualizing, adjusting, and comparing trees of hierarchical clustering. Bioinformatics. doi: 10.1093/bioinformatics/btv428
  * Raivo Kolde (2018). pheatmap: Pretty Heatmaps. R package version 1.0.10. https://CRAN.R-project.org/package=pheatmap
  * Simon Potter (2018). grImport2: Importing 'SVG' Graphics. R package version 0.1-4. https://CRAN.R-project.org/package=grImport2

For ibdSlope.R:
  * Robert J. Hijmans (2017). geosphere: Spherical Trigonometry. R package version 1.5-7. https://CRAN.R-project.org/package=geosphere
  * Xiuwen Zheng, David Levine, Jess Shen, Stephanie M. Gogarten, Cathy Laurie, Bruce S. Weir. A High-performance Computing Toolset for Relatedness and Principal Component Analysis of SNP Data. Bioinformatics 2012; doi:
10.1093/bioinformatics/bts606

For vcfToPCAvarExplained.R
  * Xiuwen Zheng, David Levine, Jess Shen, Stephanie M. Gogarten, Cathy Laurie, Bruce S. Weir. A High-performance Computing Toolset for Relatedness and Principal Component Analysis of SNP Data. Bioinformatics 2012; doi:
10.1093/bioinformatics/bts606
  * Mastretta-Yanes, A., Arrigo, N., Alvarez, N., Jorgensen, T. H., Piñero, D., & Emerson, B. C. (2015). Restriction site-associated DNA sequencing, genotyping error estimation and de novo assembly optimization for population 
genetic inference. Molecular Ecology Resources, 15(1), 28–41. doi:10.1111/1755-0998.12291


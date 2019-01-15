# clustOpt

**Dependencies**

vcftools must be installed and in the $PATH (i.e. you must be able to call vcftools from the command line by simply typing vcftools). In addition,
the following R packages must be installed:

  1) SNPRelate (http://www.bioconductor.org/packages/release/bioc/html/SNPRelate.html)
  2) pheatmap
  3) geosphere (only needed for running vcfToIBDslope.pl)
  4) grImport2
  5) dendextend
  6) ape (only needed if analyzing RAxML bootstrap values)
  7) phangorn (only needed if analyzing RAxML bootstrap values)


## Missingness heat maps ##
To calculate correlations between missingness and relatedness and generate missingness heatmaps that are clustered by genetic relatedness, use the following command:

`perl vcfMissingness.pl --vcflist <vcfListFile>`

This script does several things, including:

  1) Generates 012 format files from each of the VCF files using vcftools
  2) Calculates all pairwise missingness values from the 012 files using the included script resources/pairwiseMissingnessFrom012.pl
  3) Calculates the Pearson's correlation coefficients between data missingness and genetic relatedness
  4) Generates a color scale that is maximally informative with respect to the data and that is consistent across all VCFs for comparability
  5) Calculates SNP identity by state and clusters samples based on relatedness
  6) Draws heatmaps (one PDF per input VCF) of samples clustered by relatedness where the values indicate pairwise genotype missingness among samples


Specifically, the script vcfToMissHM.pl can be used to generate heatmaps of pairwise missingness that are clustered by genetic similarity similar to Figure 4. The script missVsGenDist.pl can be used to calculate pairwise missingness correlations as a function of genetic distance. For population genomic studies where isolation by distance is likely to play a role in the partitioning of genetic variation, vcfToIBDslope.pl can be used to generate figures similar to Figures 5B for a collection of clustering thresholds. And vcfToPCAvarExplained.pl can be used to calculate the cumulative variance explained by the most important principal components starting from a collection of VCF files. 




## Citation ##
Please cite the following papers and R packages when using the scripts below:

For vcfMissingness.pl:
  * Xiuwen Zheng, David Levine, Jess Shen, Stephanie M. Gogarten, Cathy Laurie, Bruce S. Weir. A High-performance Computing Toolset for Relatedness and Principal Component Analysis of SNP Data. Bioinformatics 2012; doi:
10.1093/bioinformatics/bts606
  * Tal Galili (2015). dendextend: an R package for visualizing, adjusting, and comparing trees of hierarchical clustering. Bioinformatics. doi: 10.1093/bioinformatics/btv428
  * Raivo Kolde (2018). pheatmap: Pretty Heatmaps. R package version 1.0.10. https://CRAN.R-project.org/package=pheatmap
  * Simon Potter (2018). grImport2: Importing 'SVG' Graphics. R package version 0.1-4. https://CRAN.R-project.org/package=grImport2

For vcfToIBDslope.pl:
  * Robert J. Hijmans (2017). geosphere: Spherical Trigonometry. R package version 1.5-7. https://CRAN.R-project.org/package=geosphere
  * 

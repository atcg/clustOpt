# clustOpt

**Dependencies**

***Other software***

vcftools (in $PATH)

***R packages***
    1) SNPRelate (http://www.bioconductor.org/packages/release/bioc/html/SNPRelate.html)
    2) png
    3) pheatmap
    4) geosphere
    5) grImport2
    6) dendextend
    7) ape (only needed if analyzing RAxML bootstrap values)
    8) phangorn (only needed if analyzing RAxML bootstrap values)

## Missingness heat maps ##
1) Generate VCF files using different clustering thresholds (using e.g. pyRAD or Stacks)

2) Create a file that lists the path to each VCF file, one per line

3) Run vcfToMissHM.pl as follows: `perl vcfToMissHM.pl --vcflist <file> --out <outputDirectory>`

To run this, vcftools must be installed and accessible from the $PATH. First, vcftools will translate VCF files into 012 format.


```bash
vcftools --vcf infile_threshold1.vcf --012 --out threshold1
vcftools --vcf infile_threshold2.vcf --012 --out threshold2
vcftools --vcf infile_threshold3.vcf --012 --out threshold3
perl pairwiseMissingnessFrom012.pl --genotypes threshold1.012 --individuals threshold1.012.indv --out threshold1.missingness
perl pairwiseMissingnessFrom012.pl --genotypes threshold2.012 --individuals threshold2.012.indv --out threshold2.missingness
perl pairwiseMissingnessFrom012.pl --genotypes threshold3.012 --individuals threshold3.012.indv --out threshold3.missingness
```


-rw-r--r--   1 evan  staff    47B Jan 14 13:52 vcfToPCAvarExplained.pl
-rw-r--r--   1 evan  staff    49B Jan 14 13:52 vcfToIBDslope.pl
-rw-r--r--   1 evan  staff    47B Jan 14 13:52 missVsGenDist.pl
-rw-r--r--   1 evan  staff    49B Jan 14 13:51 vcfToMissHM.pl


Specifically, the script vcfToMissHM.pl can be used to generate heatmaps of pairwise missingness that are clustered by genetic similarity similar to Figure 4. The script missVsGenDist.pl can be used to calculate pairwise missingness correlations as a function of genetic distance. For population genomic studies where isolation by distance is likely to play a role in the partitioning of genetic variation, vcfToIBDslope.pl can be used to generate figures similar to Figures 5B for a collection of clustering thresholds. And vcfToPCAvarExplained.pl can be used to calculate the cumulative variance explained by the most important principal components starting from a collection of VCF files. 


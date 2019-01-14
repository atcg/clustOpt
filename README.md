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

## Steps ##
1) Generate VCF files using different clustering thresholds
2) Create a file that lists the path to each VCF file, one per line
3) Run evaluateRADthresholds.pl as follows:

perl evaluateRADthresholds.pl --vcfFile <file> --out <outputDirectory> --method <missingnessVSsimilarity|missingnessVSdistance|bootstrapSupport>


```bash
vcftools --vcf infile_threshold1.vcf --012 --out threshold1
vcftools --vcf infile_threshold2.vcf --012 --out threshold2
vcftools --vcf infile_threshold3.vcf --012 --out threshold3
perl pairwiseMissingnessFrom012.pl --genotypes threshold1.012 --individuals threshold1.012.indv --out threshold1.missingness
perl pairwiseMissingnessFrom012.pl --genotypes threshold2.012 --individuals threshold2.012.indv --out threshold2.missingness
perl pairwiseMissingnessFrom012.pl --genotypes threshold3.012 --individuals threshold3.012.indv --out threshold3.missingness
```


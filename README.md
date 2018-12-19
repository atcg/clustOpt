# RADclusteringOptimization

**Dependencies**
SNPRelate (R package: http://www.bioconductor.org/packages/release/bioc/html/SNPRelate.html)


*Data generation*
1) Generate VCF files using different clustering thresholds
2) For each VCF, generate a pairwise missingness file using vcftools and the included script pairwiseMissingnessFrom012.pl:

```bash
vcftools --vcf infile.vcf --012 --out threshold1
vcftools --vcf infile.vcf --012 --out threshold2
vcftools --vcf infile.vcf --012 --out threshold3
perl pairwiseMissingnessFrom012.pl --genotypes threshold1.012 --individuals threshold1.012.indv --out threshold1.missingness
perl pairwiseMissingnessFrom012.pl --genotypes threshold2.012 --individuals threshold2.012.indv --out threshold2.missingness
perl pairwiseMissingnessFrom012.pl --genotypes threshold3.012 --individuals threshold3.012.indv --out threshold3.missingness
```


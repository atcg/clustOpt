#!/usr/bin/env perl

use strict;
use warnings;
use Getopt::Long;
use File::Basename;

my $vcflist;
my $help;
my $clustOptDir = dirname($0);

GetOptions  ("vcflist=s"   => \$vcflist,
             "help|man"    => \$help) || die "Couldn't get options with GetOpt::Long: $!\n";

if (!$vcflist or $help) {
    die "Must supply --vcflist.
    --vcflist is a file that contains one VCF filename per line, each one corresponding to a different clustering threshold\n";
}

open(my $vcfFilesFH, "<", $vcflist);
# Get the VCF filenames from the input file
my @vcfFiles;
while (my $line = <$vcfFilesFH>) {
    chomp($line);
    push(@vcfFiles, $line);
}


################################################
### Translate the VCF files into 012 format: ###
################################################
print "#### Translating VCF files into 012 format ####\n";

foreach my $vcf (@vcfFiles) {
    my $outPrefix = $1 . "_missHM012" if ($vcf =~ /(.*)\.vcf/);
    if (-e $outPrefix . '.012') {
        die "$outPrefix.012 already exists. Exiting now to prevent overwriting files\n";
    } elsif (-e $outPrefix . '.012.indv') {
        die "$outPrefix.012.indv already exists. Exiting now to prevent overwriting files\n";
    } elsif (-e $outPrefix . '.012.pos') {
        die "$outPrefix.012.pos already exists. Exiting now to prevent overwriting files\n";
    }
    system("vcftools --vcf $vcf --012 --out $outPrefix");
}
print "\n\n\n";
print "#### Finished translating VCF files into 012 format ####\n";

########################################################################
### Now use the 012 files to generate pairwise missingness matrices: ###
########################################################################

print "\n\n\n";
print "#### Generating pairwise missingness matrices from 012 files ####\n";
foreach my $vcf (@vcfFiles) {
    my $inPrefix = $1 . "_missHM012" if ($vcf =~ /(.*)\.vcf/);
    my $genotypes = $inPrefix . ".012";
    my $individuals = $inPrefix . ".012.indv";
    my $out = $inPrefix . ".missingness";
    system("perl $clustOptDir/resources/pairwiseMissingnessFrom012.pl --genotypes $genotypes --individuals $individuals --out $out");
}
print "\n\n\n";
print "#### Finished generating pairwise missingness matrices from 012 files ####\n";

###############################################################################################
### Take the missingness matrices and the underlying VCF and use them to make the heatmaps: ###
###############################################################################################

system("Rscript $clustOptDir/resources/missingnessHeatMaps.R $vcflist")

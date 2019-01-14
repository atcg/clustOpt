#!/usr/bin/perl

use strict;
use warnings;
use autodie;
use Getopt::Long;

my $genotypesFile;
my $indFile;
my $outFile;
my $help;

GetOptions  ("genotypes=s"        => \$genotypesFile,
             "individuals=s"      => \$indFile,
             "out=s"              => \$outFile,
             "help|man"     => \$help) || die "Couldn't get options with GetOpt::Long: $!\n";

if (!$genotypesFile or !$indFile or !$outFile or $help) {
    die "Usage: perl pairwiseMissingnessFromVCF.pl --genotypes <file.012> --individuals <file.indv> --out <file>";
}

# The indv file has one sample per line, in the same order as the rows in the 012 file
my @samples;
open(my $indFH, "<", $indFile);
while (my $line = <$indFH>) {
    chomp($line);
    push(@samples, $line);
}

my %genotypesHash;
open(my $genotypesFH, "<", $genotypesFile);
while (my $line = <$genotypesFH>) {
    chomp($line);
    my @fields = split(/\t/, $line);
    my $sampleIndex = shift(@fields);
    my $sample = $samples[$sampleIndex];
    foreach my $genotype (@fields) {
        push(@{$genotypesHash{$sample}}, $genotype);
    } 
}

# Get the number of loci from the first sample genotype array (this should be safe because there is always at least 1 
# sample, and there should be the same number of loci for each sample:
my $numLoci = scalar(@{$genotypesHash{$samples[0]}});
foreach my $sample (@samples) {
    if (scalar(@{$genotypesHash{$sample}}) != $numLoci) {
        die "$sample does not have the same number of loci as $samples[0]. Check to make sure each sample has the same number of genotypes\n";
    }
}

# Now do locus comparisons
my %missingness;
foreach my $locus (0..$numLoci-1) {
    if ($locus % 10000 == 0) {
        print "Processed $locus loci\n";
    }
    foreach my $sampleIndex1 (0..scalar(@samples)-1) {
        foreach my $sampleIndex2 ($sampleIndex1..scalar(@samples)-1) {
            if (${$genotypesHash{$samples[$sampleIndex1]}}[$locus] == -1 and ${$genotypesHash{$samples[$sampleIndex2]}}[$locus] == -1) {
                $missingness{$samples[$sampleIndex1]}{$samples[$sampleIndex2]}{'bothmiss'}++;
            } elsif (${$genotypesHash{$samples[$sampleIndex1]}}[$locus] != -1 and ${$genotypesHash{$samples[$sampleIndex2]}}[$locus] != -1) {
                $missingness{$samples[$sampleIndex1]}{$samples[$sampleIndex2]}{'neithermiss'}++;
            } elsif (${$genotypesHash{$samples[$sampleIndex1]}}[$locus] == -1 and ${$genotypesHash{$samples[$sampleIndex2]}}[$locus] != -1) {
                $missingness{$samples[$sampleIndex1]}{$samples[$sampleIndex2]}{'onemiss'}++;
            } elsif (${$genotypesHash{$samples[$sampleIndex1]}}[$locus] != -1 and ${$genotypesHash{$samples[$sampleIndex2]}}[$locus] == -1) {
                $missingness{$samples[$sampleIndex1]}{$samples[$sampleIndex2]}{'onemiss'}++;
            } else {
                die "Impossible genotype combination: ${$genotypesHash{$samples[$sampleIndex1]}}[$locus] and ${$genotypesHash{$samples[$sampleIndex2]}}[$locus]\n";
            }
        }
    }
}

open(my $outFH, ">", $outFile);
print $outFH "Sample1\tSample2\tneitherMiss\tbothMiss\toneMiss\n";
foreach my $sampleIndex1 (0..scalar(@samples)-1) {
    foreach my $sampleIndex2 ($sampleIndex1..scalar(@samples)-1) {
        print $outFH $samples[$sampleIndex1] . "\t" . $samples[$sampleIndex2] . "\t";
        if (exists $missingness{$samples[$sampleIndex1]}{$samples[$sampleIndex2]}{'neithermiss'}) {
            print $outFH $missingness{$samples[$sampleIndex1]}{$samples[$sampleIndex2]}{'neithermiss'} . "\t";
        } else {
            print $outFH "NA\t";
        }

        if (exists $missingness{$samples[$sampleIndex1]}{$samples[$sampleIndex2]}{'bothmiss'}) {
            print $outFH $missingness{$samples[$sampleIndex1]}{$samples[$sampleIndex2]}{'bothmiss'} . "\t";
        } else {
            print $outFH "NA\t";
        }

        if (exists $missingness{$samples[$sampleIndex1]}{$samples[$sampleIndex2]}{'onemiss'}) {
            print $outFH $missingness{$samples[$sampleIndex1]}{$samples[$sampleIndex2]}{'onemiss'} . "\n";
        } else {
            print $outFH "NA\n";
        }
    }
}

#!/usr/bin/perl -w

use strict;

my $file=shift or die "Usage: $0 <2nd_haplo_shuffle>\n";

print "##fileformat=VCFv4.1\n##reference=hg38\n";
print "##FORMAT=<ID=GT,Number=1,Type=String,Description=\"Genotype\">\n";
print "##FORMAT=<ID=DP,Number=1,Type=Integer,Description=\"Read Depth\">\n";
print "##FORMAT=<ID=AO,Number=A,Type=Integer,Description=\"Alternate allele observation count\">\n";
print "##FORMAT=<ID=QA,Number=A,Type=Integer,Description=\"Sum of quality of the alternate observations\">\n";
print "##FORMAT=<ID=PS,Number=1,Type=Integer,Description=\"ID of Phase Set for Variant\">\n";
print "##FORMAT=<ID=PQ,Number=1,Type=Integer,Description=\"Phred QV indicating probability at this variant is incorrectly phased\">\n";
print "##FORMAT=<ID=JQ,Number=1,Type=Integer,Description=\"Phred QV indicating probability of a phasing switch error in gap prior to this variant\">\n";

open my $file_h,'<',$file;
while(<$file_h>){
	my @line=split;
	next unless $line[-1]=~/^1\|0/ or $line[-1]=~/^0\|1/ or $line[-1]=~/^1\|1/;
	$line[-1]=~s/PASS;//;
	print "$line[0]\t$line[1]\t\.\t$line[2]\t$line[3]\t\.\t\.\t\.\t","GT:PS:PQ:JQ:DP:AO:QA","\t$line[-1]\n";
}


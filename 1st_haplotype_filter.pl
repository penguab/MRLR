#!/usr/bin/perl -w
#filter low quality and ambiguous haplotype sites;
use strict;

my $file=shift || die "Usage: $0  <1st_haplo_mutation_rm>\n";

open my $fileh,'<',$file;
while(<$fileh>){
        my @line=split;
	my $mark=0;
	foreach my $i(6){
		unless($line[$i]=~/^[01]\|[01]/){
        	       $mark=1;
			last;
	        }
		my @F=split /;/,$line[$i];
	        if($F[1]eq"-" or $F[4]eq"unpass"){
                	$mark=1;
			last;
	        }
		if($F[-1] eq "-" and $F[0] ne "0|0"){
			$mark=1;
                        last;
		}
	        if($F[-1]ne"-"){
			if ($F[-2]<5 or $F[-1]/$F[-2]<30){
		                $mark=1;
				last;
			}
	        }
	}
	if($mark==0){
		print join "\t",@line,"\n";
	}
}

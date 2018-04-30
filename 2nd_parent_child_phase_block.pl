#!/usr/bin/perl -w
#
use strict;

my $file=shift or die "Usage: $0 <parent_offspring_haplotype.file>\n";

my $start;
my $end;
my $chr;
my %info;

open my $fileh,'<',$file;

while(<$fileh>){
	chomp;
	my @line=split;	
	my $p=(split /;/,$line[2])[1];
	my $o=(split /;/,$line[3])[1];
	my $pos=$p.";".$o;
	if(!defined($start)){
		$start=$line[1];
		$end=$line[1];
		$chr=$line[0];	
		$info{$start}=$pos;
	}
	else{
		if(($line[0] eq $chr)and($info{$start} eq $pos)){
			$end=$line[1];
		}
		else{
			my $len=$end-$start+1;
			print $chr,"\t",$start,"\t",$end,"\t",$len,"\t",$info{$start},"\n";
			$start=$line[1];
			$end=$line[1];
			$chr=$line[0];
			$info{$start}=$pos;
		}
	}
}

if(eof($fileh)){
        my $len=$end-$start+1;
	print $chr,"\t",$start,"\t",$end,"\t",$len,"\t",$info{$start},"\n";
}


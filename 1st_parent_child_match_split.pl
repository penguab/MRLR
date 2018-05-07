#!/usr/bin/perl -w 
use strict;

my $file=shift ||die "Usage: $0 <parent_offspring_match.file>\n";
open my $fileh,'<',$file;

while(<$fileh>){
	next if /\t\.\t\.\t\.\t\./;
	my @line=split;
	my ($ten_s,$ten_e)=(".",".");
	my $mark1=0;
	my $n=int($line[-1]/10000);
	foreach my $i (0..$n-1){
		if($line[1]>=$line[-3]+$i*10000 and $line[1]<$line[-3]+($i+1)*10000){
			$ten_s=$line[-3]+$i*10000;
			$ten_e=$line[-3]+($i+1)*10000-1;
			$mark1=1;
		}
		if($mark1==1){
			last;
		}
	}
	print join "\t", @line;
	print "\t$ten_s\t$ten_e\n";

}












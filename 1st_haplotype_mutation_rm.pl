#!/usr/bin/perl -w
#filter mutation sites inconsistent with inheritance;
use strict;

my $file=shift || die "Usage: $0  <1st_haplo_sort_mask>\n";
my %info;
open my $fileh,'<',$file;
while(<$fileh>){
        my @line=split;
        my $pos="$line[0]\t$line[1]";
        if(!defined($info{$pos})){
                $info{$pos}=0;
        }
        $info{$pos}++;
}
close $fileh;

open $fileh,'<',$file;
while(<$fileh>){
        my @line=split;
	my $pos="$line[0]\t$line[1]";
        next if $info{$pos}>1;
	my ($F1,$F2,$M1,$M2,$C1,$C2);
	if($line[4]=~/^(\d)\D(\d);/){
		$F1=$1;
		$F2=$2;
	}
	if($line[5]=~/^(\d)\D(\d);/){
                $M1=$1;
                $M2=$2;
        }
	if($line[6]=~/^(\d)\D(\d);/){
                $C1=$1;
                $C2=$2;
        }
	if((($F1==1 and $F2==1) or ($M1==1 and $M2==1)) and ($C1==0 and $C2==0)){
		next;
	}
	if((($F1==0 and $F2==0) or ($M1==0 and $M2==0)) and ($C1==1 and $C2==1)){
                next;
        }
	if(($C1==1 and $C2==0) or ($C1==0 and $C2==1)){
                if(($F1==0 and $F2==0 and $M1==0 and $M2==0) or ($F1==1 and $F2==1 and $M1==1 and $M2==1)){
			next;
		}
        }
	print join "\t",@line,"\n";
}

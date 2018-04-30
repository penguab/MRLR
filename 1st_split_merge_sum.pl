#!/usr/bin/perl -w 
#
use strict;
my $file =shift or die "Usage: $0 <1st_split_merge>";

open my $file_h,'<',$file;

while (<$file_h>){
	my @line=split;
	my $hap1=$line[13];
	my $hap2=$line[-1];
	$hap1=~s/:.*//g;
	$hap2=~s/:.*//g;
	my $sym;
	my $total;
	if(defined((split /-/,$hap1)[1]) && defined((split /-/,$hap2)[1]) && (split /-/,$hap1)[1] eq (split /-/,$hap2)[1]){
		$sym="error";
		$total="-";
	}
	elsif(defined((split /-/,$hap1)[1]) &&  defined((split /-/,$hap2)[1]) && (split /-/,$hap1)[1] ne (split /-/,$hap2)[1]){
                $sym="high";
		$total=$hap1;
        }
	elsif(defined((split /-/,$hap1)[1]) && $hap2 eq "-"){
                $sym="low";
		$total=$hap1;
        }
	elsif(defined((split /-/,$hap2)[1]) && $hap1 eq "-"){
                $sym="low";
		if((split /-/,$hap2)[1]==1){
			$total="0-2";
		}
		elsif((split /-/,$hap2)[1]==2){
			$total="0-1";
		}
        }
	elsif($hap1 eq "-" and $hap2 eq "-"){
		$sym="-";
		$total="-";
	}
	else{
		$sym="strange";
		$total="-";
	}
	print "$line[0]\t$line[1]\t$line[2]\t$line[3]\t$line[4]\t$hap1\t$hap2\t$sym\t$total\n";
}


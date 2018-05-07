#!/usr/bin/perl -w
#
use strict;

my $haplo=shift or die "Usage: $0 <haplotype.file> <phase_block.file>\n";
my $block=shift or die "Usage: $0 <haplotype.file> <phase_block.file>\n";

my $gender;
if($haplo=~/_(\w)_C/){
	$gender=$1;
}

open my $block_h,'<',"$block";
my $region=<$block_h>;
chomp $region;
my $start=(split /\t/,$region)[1];
my $end=(split /\t/,$region)[2];
my $chr=(split /\t/,$region)[0];
my $len=(split /\t/,$region)[3];
my $new=1;
open my $haplo_h,'<',"$haplo";
while(<$haplo_h>){
	chomp;
	my @line=split;
	if($new==1 and $line[0] ne $chr){
		next;
	}
	if((($line[0] eq $chr and  $line[1] > $end) or ($line[0] ne $chr)) and !eof($block_h)){
		$region=<$block_h>;
		chomp $region;
		if($chr ne (split /\t/,$region)[0]){
			$new=1;
		}else{
			$new=0;
		}
		$start=(split /\t/,$region)[1];
		$end=(split /\t/,$region)[2];
		$chr=(split /\t/,$region)[0];
		$len=(split /\t/,$region)[3];
	}
	if($line[0] eq $chr and $line[1] >=$start and $line[1] <= $end){
		my ($p_f,$p_r,$o_f,$o_r); #p-parent;f-foward haplotype;r-reverse haplotype;o-offspring;
		if($line[4]=~/^(.*)\|([^;]*);/){
			$p_f=$1;
			$p_r=$2;
		}
		if($line[5]=~/^(.*)\|([^;]*);/){
                        $o_f=$1;
                        $o_r=$2;
                }
		my $sym;
		if($gender eq "F" and $p_f eq $o_f and $p_f eq $p_r){
                        $sym="0-1";
                }
		elsif($gender eq "F" and $p_f eq $o_f){
			$sym="1-1";
		}
		elsif($gender eq "F" and $p_r eq $o_f){
                        $sym="2-1";
                }
		elsif($gender eq "M" and $p_f eq $o_r and $p_f eq $p_r){
                        $sym="0-2";
                }
		elsif($gender eq "M" and $p_f eq $o_r){
		        $sym="1-2";
                }
		elsif($gender eq "M" and $p_r eq $o_r){
                        $sym="2-2";
                }
                else{
                        $sym="wrong";
                }
		print join "\t",@line[0..5];
		print "\t$sym\t$start\t$end\t$len\n";
	}else{
		print join "\t",@line[0..5];
                print "\t\.\t\.\t\.\t\.\n";
	}
}






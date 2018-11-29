#!/usr/bin/perl -w 
#
use strict;
my ($a,$b,$l,$p,$s,$file1)=@ARGV;

open my $file1_h,'<',$file1 || die "Usage: $0 -a -b -l -p -s <test_candidate_sum_high>\n";

print "Chr\tBlock_start\tBlock_end\tLeft_arm_hap_cor\tLeft_start\tLeft_end\tLeft_SNVs\tRight_arm_hap_cor\tRight_start\tRight_end\tRight_SNVs\tBreakpoint_start\tBreakpoint_end\tBreakpoint_length\tParent_support_barcode\tParent_deny_barcode\tChild_support_barcode\tChild_deny_barcode\n";

while(<$file1_h>){
	my @F=split;
	my $block=$F[2]-$F[1]+1;
	my $barcode1=$F[-7];
	my $barcode2=$F[-4];
	my $arm1=$F[5]-$F[4]+1;
	my $arm2=$F[9]-$F[8]+1;
	my $breakpoint=$F[-8];
	my $snp1=$F[6];
	my $snp2=$F[10];
	next if  $F[-3]/$F[-4]>=0.1 or $F[-6]/$F[-7]>=0.1;
        next if $F[2]-$F[5]>=100000 && $F[4]-$F[1]>=100000 && $snp1<=100;
        next if $F[2]-$F[9]>=100000 && $F[8]-$F[1]>=100000 && $snp2<=100;
	if($block>=$l*1000 && $barcode1>=$b && $barcode2>=$b && $arm1>=$a*1000 && $arm2>=$a*1000 && $breakpoint<=$p*1000 && $snp1>=$s && $snp2>=$s){
		print join "\t",@F[0..15],@F[17..18];
		print "\n";
	}
}
close $file1_h;


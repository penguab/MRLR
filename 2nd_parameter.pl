#!/usr/bin/perl -w 
#
use strict;
my $file1=shift or die "Usage: $0 <test_candidate_sum_high>\n";

print "Chr\tBlock_start\tBlock_end\tLeft_arm_hap_cor\tLeft_start\tLeft_end\tLeft_SNVs\tRight_arm_hap_cor\tRight_start\tRight_end\tRight_SNVs\tBreakpoint_start\tBreakpoint_end\tBreakpoint_length\tParent_support_barcode\tParent_deny_barcode\tParent_barcode_sum\tChild_support_barcode\tChild_deny_barcode\tChild_barcode_sum\tBreakpoint_confidence\n";

open my $file1_h,'<',$file1;

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
	if($block>=500000 && $barcode1>=4 && $barcode2>=4 && $arm1>=20000 && $arm2>=20000 && $breakpoint<=100000 && $snp1>=20 && $snp2>=20){
		print join "\t",@F;
		print "\n";
	}
}
close $file1_h;


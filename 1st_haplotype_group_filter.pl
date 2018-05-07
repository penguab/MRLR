#!/usr/bin/perl -w
#extract one parent and child genome; further filter no snp site;

use strict;

my $file=shift || die "Usage: $0 <haplo_filter> <gender:Father/Mother>\n";
my $gender=shift || die "Usage: $0 <haplo_filter> <gender:Father/Mother>\n";

my ($f,$s);
if($gender=~/^F/){
	$f=4;
}elsif($gender=~/^M/){
	$f=5;
}else{
	die "specify gender: Father/Mother\n";
}

$s=6;

open my $fileh,'<',$file;
while(<$fileh>){
	my @line=split;
        unless($line[$f]=~/^[01]\|[01]/){
                next;
        }
        unless($line[$s]=~/^[01]\|[01]/){
                next;
        }
	my @F=split /;/,$line[$f];
	if($F[1]eq"-" or $F[4]eq"unpass"){
		next;
	}
	if($F[-1]ne"-"){
		if($F[-2]<5 or $F[-1]/$F[-2]<30){
			next;
		}
	}
	my @S=split /;/,$line[$s];
        if($S[1]eq"-" or $S[4]eq"unpass"){
                next;
        }
        if($S[-1]ne"-"){
                if($S[-2]<5 or $S[-1]/$S[-2]<30){
                        next;
                }
        }
	if($F[0]eq"0|0" and $S[0]eq"0|0"){
                next;
        }
	print "$line[0]\t$line[1]\t$line[2]\t$line[3]\t$line[$f]\t$line[$s]\n"
}


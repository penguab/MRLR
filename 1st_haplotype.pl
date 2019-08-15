#!/usr/bin/perl -w

use strict;

my @in=@ARGV;
die "no input vcf files\n" unless ($#in==2);

my %spe;
my $n=0;
my %out;
my %mark;

foreach my $speid (@in){
my $fileh;
open $fileh,'<', $speid or die "Can't open vcf file\n";
while(<$fileh>){
	next if /#/;
	chomp;
	my @line=split /\t/, $_;
	unless (exists $spe{$speid}){
		$spe{$speid}=$n;
		$n++;
	}
	my ($pass,$PS,$PQ,$JQ,$DP,$AO,$QA)=("unpass","-","-","-","-","-","-");
	if($line[6]eq"PASS"){
		$pass="PASS";	
	}
	my $pos=$line[0]."\t".$line[1]."\t".$line[3]."\t".$line[4];
	my @sym=split /:/,$line[-2];
	my @cont=split /:/,$line[-1];
	my %info;
	foreach my $i(0..$#sym){
		$info{$sym[$i]}=$cont[$i];
	}
	if(! exists $info{"AO"}){
		if(exists  $info{"AD"}){
			$info{"AO"}=(split /,/, $info{"AD"})[1];
			$info{"QA"}=$info{"AO"}*30;
		}
	}
	if(exists $info{"PS"} and exists  $info{"DP"} and exists  $info{"AO"} and exists  $info{"QA"}){
		$PS=$info{"PS"};
		$PQ=$info{"PQ"} if exists $info{"PQ"};
		$JQ=$info{"JQ"} if exists $info{"JQ"};
		$DP=$info{"DP"};
		$AO=$info{"AO"};
		$QA=$info{"QA"};
	}
	my $haplo="0/0";
	if($line[-1]=~/^(\d[\/\|]\d):.*/){
		$haplo=$1;
	}
	unless(exists $mark{$pos}){
		foreach(0..2){
			${$out{$pos}}[$_]=".";
		}
		$mark{$pos}=1;	
	}
	${$out{$pos}}[$spe{$speid}]=$haplo.";".$PS.";".$PQ.";".$JQ.";".$pass.";".$DP.";".$AO.";".$QA;
}
close $fileh;
}


print "Chr0\tsite\tRef\tAlt\t",join "\t",@in,"\n";

foreach my $id(keys %out){
	my $tab=join "\t",@{$out{$id}};
	print $id,"\t",$tab,"\n";
}


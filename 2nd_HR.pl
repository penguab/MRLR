#!/usr/bin/perl -w 
#
use strict;

my $file = shift ||die "Usage: $0 <2nd_NA12878_candidate_CO>\n";
my $before;
my $pre_id;
open my $file_h,'<',$file;
while(<$file_h>){
	my @line=split;
	my $id="$line[0]\t$line[4]\t$line[5]";
	if(!defined($before)){
		$before=join "\t",@line;
		$pre_id="$line[0]\t$line[4]\t$line[5]";
		next;
	}
        if(defined($before) &&($id eq $pre_id)){
		my @array=split "\t",$before;
		my $len=$line[1]-$array[2]+1;
                print "$array[0]\t$array[4]\t$array[5]\t$array[3]\t$array[1]\t$array[2]\t$array[6]\t";
                print "$line[3]\t$line[1]\t$line[2]\t$line[6]\t";
		print "$array[2]\t$line[1]\t$len\n";
	}
	$before=join "\t",@line;
	$pre_id="$line[0]\t$line[4]\t$line[5]";
}



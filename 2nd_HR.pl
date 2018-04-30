#!/usr/bin/perl -w 
#
use strict;

my $file = shift ||die "Usage: $0 <2nd_merge_split_match_HR>\n";
my $before;
my $pre_id;
open my $file_h,'<',$file;
while(<$file_h>){
	my @line=split;
	my $id="$line[0]\t$line[1]\t$line[2]";
	if(!defined($before)){
		$before=join "\t",@line;
		$pre_id="$line[0]\t$line[1]\t$line[2]";
		next;
	}
        if(defined($before) &&($id eq $pre_id)){
		my $len=$line[4]-(split "\t",$before)[-2]+1;
                print $before,"\t";
                print "$line[3]\t$line[4]\t$line[5]\t$line[6]\t$len\n";

	}
	$before=join "\t",@line;
	$pre_id="$line[0]\t$line[1]\t$line[2]";
}



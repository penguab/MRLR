#!/usr/bin/perl -w 
#
use strict;

my $file = shift ||die "Usage: $0 <merge_F_M_match_somHR>\n";
my $before;
my $pre_id;
open my $file_h,'<',$file;
while(<$file_h>){
	my @line=split;
	my $id="$line[-1]\t$line[0]\t$line[1]\t$line[2]";
	if(!defined($before)){
		$before=join "\t",@line;
		$pre_id="$line[-1]\t$line[0]\t$line[1]\t$line[2]";
		next;
	}
        if(defined($before) &&($id eq $pre_id)&& $line[-3]>=10 &&(split /\t/,$before)[-3]>=10 && $line[-2]>=3 && (split /\t/,$before)[-2]>=3){
                print $before,"\t";
                print "$line[3]\t$line[4]\t$line[5]\t$line[6]\t$line[7]\n";

	}
	$before=join "\t",@line;
	$pre_id="$line[-1]\t$line[0]\t$line[1]\t$line[2]";
}



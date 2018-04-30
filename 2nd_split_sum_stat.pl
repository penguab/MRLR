#!/usr/bin/perl -w
##
use strict;

my $file = shift or die "Usage: $0 <2nd_merge_split_50k_match>\n";
my $before;
my $sum;
my $start;
my $end;
my @array;
open my $file_h,'<',$file;
while(<$file_h>){
	my @line=split;
	next if $line[-1] eq "-";
	$line[-1]=~s/:.*//g;
	my $id="$line[0]\t$line[3]\t$line[4]\t$line[-1]";
	if(defined($before) &&($id eq $before)){
		$end=$line[2];
		$sum++;
	}
	else{
		if(defined($before) && ($id ne $before)){
			if($sum>=5){
				push @array, "$before\t$start\t$end\t$sum";
			}
		}
		$before=$id;
		$sum=1;
		$start=$line[1];
		$end=$line[2];
	}
}

if(eof($file_h)){
	if($sum>=5){
                push @array, "$before\t$start\t$end\t$sum";
        }
}

my $pre_id;
foreach my $id (@array){
	if(defined($pre_id)){
		my @line=split /\t/,$id;
		my @pre_line=split /\t/,$pre_id;
		if("$pre_line[0]\t$pre_line[1]\t$pre_line[2]\t$pre_line[3]" eq "$line[0]\t$line[1]\t$line[2]\t$line[3]"){
			$pre_line[-2]=$line[-2];
			$pre_line[-1]+=$line[-1];
			$pre_id=join "\t",@pre_line;
		}
		else{
			print $pre_id,"\n";
			$pre_id=$id;
		}
	}
	else{
		$pre_id=$id;
	}
}

print $pre_id,"\n";


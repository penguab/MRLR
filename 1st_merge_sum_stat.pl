#!/usr/bin/perl -w
##
use strict;

my $file = shift or die "Usage: $0 <merge_match.10k_sum_intersect>\n";
my @F_HR=&array($file,8);

sub array{
my ($file,$n)=@_;
my $before;
my ($sum,$high);
my $start;
my $end;
my @array;
open my $file_h,'<',$file;
while(<$file_h>){
	my @line=split;
	next if $line[7] eq "-";
	my $sym=$line[$n];
	$line[$n]=~s/^\d-/0-/;
	my $id="$line[0]\t$line[3]\t$line[4]\t$line[$n]";
	if(defined($before) &&($id eq $before)){
		$end=$line[2];
		$sum++;
		if($line[7]eq"high"){
			$high++;
		}
	}
	else{
		if(defined($before) && ($id ne $before)){
			if($sum>=5 and $high>=1){
				print "$before\t$start\t$end\t$sum\t$high\tFather-Child\n";
			}
		}
		$before=$id;
		$sum=1;
		if($line[7]eq"high"){
                        $high=1;
                }else{
			$high=0;
		}
		$start=$line[1];
		$end=$line[2];
	}
}

if(eof($file_h)){
	if($sum>=5 and $high>=1){
                push @array, "$before\t$start\t$end\t$sum\t$high\tFather-Child\n";
        }
}
return @array;
}


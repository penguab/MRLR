#!/usr/bin/perl -w 
#
use strict;
my $stat=shift or die "Usage: $0 <1st_split_merge_sum_stat> <haplo_sort_mask>\n";
my $haplo=shift or die "Usage: $0 <1st_split_merge_sum_stat> <haplo_sort_mask>\n";

my $n=6;
open my $stat_h,'<',$stat;
my $info=<$stat_h>;
chomp $info;
my @cont=split /\t/,$info;
my $start=$cont[4];
my $end=$cont[5];
my $chr=$cont[0];
my $new=1;
open my $haplo_h,'<',$haplo;

while(<$haplo_h>){
	my @line=split;
	if($new==1 and $line[0] ne $chr){
		next;
	}
	if((($line[0] eq $chr and $line[1]>$end) or $line[0] ne $chr) and !eof($stat_h)){
		$info=<$stat_h>;
		chomp $info;
		@cont=split /\t/,$info;
		if($cont[0] ne $chr){
			$new=1;
		}else{
			$new=0;
		}
		$start=$cont[4];
		$end=$cont[5];
		$chr=$cont[0];
        }
	my @inside=split /;/,$line[$n];
	if($line[0] eq $chr and $line[1]>=$start and $line[1]<=$end){
		if( $cont[3]=~/-1/){
			$inside[1]=0;
		}
		elsif( $cont[3]=~/-2/){
			$inside[0]=~s/(\d)([^\d])(\d)/$3$2$1/;
                        $inside[1]=0;
                }
		$line[$n]=join ";",@inside;
		print join "\t",@line;
		print "\n";
	}
}

close $haplo_h;
close $stat_h;

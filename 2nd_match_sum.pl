#!/usr/bin/perl -w
##
use strict;

my $file = shift or die "Usage: $0 <2nd_NA12878_P_C_match>\n";

my $before;
my ($sum,$high);
my $start;
my $end;
my @array;
open my $file_h,'<',$file;
while(<$file_h>){
	my @line=split;
	next if /\.\t\.\t\./;
	next if $line[-4]=~/^0-/ or  $line[-4]=~/wrong/;
	my $id="$line[0]\t$line[-3]\t$line[-2]\t$line[-4]";
	if(defined($before) &&($id eq $before)){
		$end=$line[1];
		$sum++;
	}
	else{
		if(defined($before) && ($id ne $before)){
			if($sum>=3){
				my @tmp=split /\t/,$before;
				push @array, "$tmp[0]\t$start\t$end\t$tmp[3]\t$tmp[1]\t$tmp[2]\t$sum";
			}
		}
		$before=$id;
		$sum=1;
		$start=$line[1];
		$end=$line[1];
	}
}

if(eof($file_h)){
	if($sum>=3){
		my @tmp=split /\t/,$before;
                push @array, "$tmp[0]\t$start\t$end\t$tmp[3]\t$tmp[1]\t$tmp[2]\t$sum";
        }
}

my $pre_id;
foreach my $id (@array){
        if(defined($pre_id)){
                my @line=split /\t/,$id;
                my @pre_line=split /\t/,$pre_id;
                if("$pre_line[0]\t$pre_line[3]\t$pre_line[4]\t$pre_line[5]" eq "$line[0]\t$line[3]\t$line[4]\t$line[5]"){
                        $pre_line[2]=$line[2];
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



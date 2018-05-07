#!/usr/bin/perl -w
#
use strict;

my $file=shift or die "Uasge: $0 <2nd_P_C_match_sum>\n";
my $before;
my ($sum,$high);
my $start;
my $end;
my @array;

open my $file_h,'<',$file;
while(<$file_h>){
        my @line=split;
	next if $line[-1]<10 or $line[2]-$line[1]<10000;
        my $id="$line[0]\t$line[4]\t$line[5]\t$line[3]";
        if(defined($before) &&($id eq $before)){
                $end=$line[2];
                $sum+=$line[-1];
        }
        else{
                if(defined($before) && ($id ne $before)){
                        if($sum>=10 and $end-$start>=10000){
				my @tmp=split /\t/,$before;
                                push @array, "$tmp[0]\t$start\t$end\t$tmp[3]\t$tmp[1]\t$tmp[2]\t$sum";
                        }
                }
                $before=$id;
                $sum=$line[-1];
                $start=$line[1];
                $end=$line[2];
        }
}
if(eof($file_h)){
        if($sum>=10 and $end-$start>=10000){
		my @tmp=split /\t/,$before;
                push @array, "$tmp[0]\t$start\t$end\t$tmp[3]\t$tmp[1]\t$tmp[2]\t$sum";
        }
}

my $pre;
foreach my $id (@array){
        if(defined($pre)){
                my @line=split /\t/,$id;
                my @pre_line=split /\t/,$pre;
                if("$pre_line[0]\t$pre_line[3]\t$pre_line[4]\t$pre_line[5]" eq "$line[0]\t$line[3]\t$line[4]\t$line[5]"){
                        $pre_line[2]=$line[2];
                        $pre_line[-1]+=$line[-1];
                        $pre=join "\t",@pre_line;
                }
                else{
                        print $pre,"\n";
                        $pre=$id;
                }
        }
        else{
                $pre=$id;
        }
}

print $pre,"\n";


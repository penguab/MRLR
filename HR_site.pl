#!/usr/bin/perl -w 
#
use strict;

my $cand=shift || die "Usage: $0 <2nd_merge_split_match_HR_candidate> <2nd_split__match>\n";
my $match=shift || die "Usage: $0 <2nd_merge_split_match_HR_candidate> <2nd_split__match>\n";

my %info;
my %block;
my %region;
open my $cand_h,'<',$cand;

while(<$cand_h>){
	my @line=split;
	my $start=$line[5];
	my $end=$line[8]+10000-1;
	$info{"$line[0]\t$start"}="$line[3]\t$end\t$line[7]";
	$block{"$line[0]\t$start"}="$line[1]\t$line[2]";
	$region{"$line[0]\t$start"}="$line[3]\t$line[4]\t$line[5]\t$line[7]\t$line[8]\t$line[9]";
}
close $cand_h;

my $through=0;
my $chr;
my $block;
my $region;
my $len;
my @cont;
my $sum=0;
my %num;
my @amount;
open my $match_h,'<',$match;
while(<$match_h>){
	my @line=split;
	my $id="$line[0]\t$line[-1]";
	if($through ==1 && ($line[1]>$cont[1] or $line[0] ne $chr or eof($match_h))){
                my @array=sort {$b <=> $a} @amount;
		#print join "\t",@array,"\n";
		my $mark=0;
		my $max;
		my ($left,$right)=((split "\t",$region)[2]-10000,(split "\t",$region)[4]+10000);
                foreach(sort {$a <=> $b} keys %num){
                         if($mark==1 and $array[0] < $max and $num{$_} eq $array[0]){
                                $right=$_;
                                last;
                         }
			 if($num{$_} eq $array[0]){
                                if($mark==0){
					$left=$_;
					$max=$array[0];
					$mark=1;
				}
				shift @array;
                        }
                }
		#print join "\t",@array,"\n";
                print "$chr\t$block\t$region\t$len\t$left\t$right\t",$right-$left+1,"\n";
                $through=0;
		$sum=0;
		@amount=();
		%num=();
        }
	if(exists $info{$id}){
                $through=1;
                $chr=$line[0];
                $block=$block{$id};
                $region=$region{$id};
                $len=(split /\t/, $region)[4]-(split /\t/, $region)[2];
                @cont=split "\t",$info{$id};
        }
	 if($through==1){
                my $control=$sum;
                foreach my $n (4..7){
                        if($line[$n] eq $cont[0]){
                                $sum++;
                        }
                        elsif($line[$n] eq $cont[-1]){
                                $sum--;
                        }
                }
                if($sum != $control){
                        $num{$line[1]}=$sum;
                        push @amount,$sum;
                }
        }
}


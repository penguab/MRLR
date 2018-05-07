#!/usr/bin/perl -w
#add haplotype and phase set to  homozygous site;
use strict;
no strict 'refs';

my $file=shift or die "Usage:$0 <1st_haplo_sort>\n";

foreach my $n (4..6){
	open my $fileh,'<',$file;
	my $chr;
	my $start;
	my $end;
	my $code;
	my $out=$n."_out.tmp";
	while(<$fileh>){
		next if /Chr0/;
		my @line=split;
		my @cont;
		next unless $line[$n]=~/.*;.*;.*;/;
		@cont=split /;/,$line[$n];
		next if $cont[1] eq "-";
		if(!defined ($chr)){
			$chr=$line[0];
			$start=$line[1];
			$end=$line[1];
			$code=$cont[1];
		}
		else{
			if($line[0] eq $chr and $cont[1] eq $code){
				$end=$line[1];
			}
			else{
				open my $outh,'>>',$out;
				print $outh "$chr\t$start\t$end\t$code\n";
				close $outh;
				$chr=$line[0];
                      		$start=$line[1];
                               	$end=$line[1];
                               	$code=$cont[1];
			}
		}
	}
        if(eof($fileh)){
                 open my $outh,'>>',$out;
                 print $outh "$chr\t$start\t$end\t$code\n";
                 close $outh;
	}
	close $fileh;
}

my $handle;
foreach my $n (4..6){
	my $in=$n."_out.tmp";
	$handle=$n."_file";
	open $handle,'<',$in or die "can't open out.tmp.files\n";
}

my @start;
my @end;
my @chr;
my @code;

open my $fileh,'<',$file;
while(<$fileh>){
	next if /Chr0/;
	my @line=split;
	foreach my $n (4..6){
		if(!defined($start[$n-4])){
			$handle=$n."_file";
			my $input=<$handle>;
			chomp $input; 
			if(!defined($input)){
				 die "difficult in open file\n";
			}
			my @input=split /\t/,$input;
			$chr[$n-4]=$input[0];
			$start[$n-4]=$input[1];
			$end[$n-4]=$input[2];
			$code[$n-4]=$input[3];
			if($line[$n]=~/^\.$/){
				$line[$n]="0|0;-;-;-;-;-;-;-";
			}
		}
		else{
			if($line[0] eq $chr[$n-4] and $line[1]>=$start[$n-4] and $line[1]<=$end[$n-4]){
				if($line[$n]=~/^\.$/){
					$line[$n]="0|0;$code[$n-4];-;-;-;-;-;-";	
				}
			}
			else{
				if($line[$n]=~/^\.$/){
					$line[$n]="0|0;-;-;-;-;-;-;-";
				}
			}
			if($line[0] eq $chr[$n-4] and $line[1]==$end[$n-4]){
				$handle=$n."_file";
				unless(eof($handle)){
					my $input=<$handle> ;
					chomp $input;
					if(!defined($input)){
                                		 die "bad in open \n";
                        		}
               		         	my @input=split /\t/,$input;
                	        	$chr[$n-4]=$input[0];
                       		 	$start[$n-4]=$input[1];
                        		$end[$n-4]=$input[2];
					$code[$n-4]=$input[3];
				}
			}
		}
	}
	print join "\t",@line;
	print "\n";
}
close $fileh;

foreach my $n (4..6){
	$handle=$n."_file";
	close $handle;
}

 `rm *_out.tmp`;

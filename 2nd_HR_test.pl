#!/usr/bin/perl -w 
#
use strict;

my $file=shift or die "Usage: $0 <2nd_P_C_HR> <vcf files>\n";
my $vcf=shift or  die "Usage: $0 <2nd_P_C_HR> <vcf files>\n";

my $mark=0;
my @out;
open my $file_h,'<',$file;
my $site=<$file_h>;
chomp $site;
my @site=split /\t/,$site;

my (@seq1,@seq2,@seq3,@seq4);
my $pos;
open my $vcf_h,'<',$vcf;
while(<$vcf_h>){
	next if /#/;
	my $skip=0;
	my @line=split;
	my @symb=split /:/,$line[-2];
	my @cont=split /:/,$line[-1];
	my %info;
	foreach (0..$#symb){
		$info{$symb[$_]}=$cont[$_];
	}
	next unless(exists $info{"RO"} and exists $info{"AO"} and exists $info{"BX"} and exists $info{"PS"});
	next unless ($info{"RO"}>=3 and $info{"QR"}/$info{"RO"}>=30 and $info{"AO"}>=3 and $info{"QA"}/$info{"AO"}>=30 and $line[6] eq "PASS");
	next unless ($info{"GT"} eq "1|0" or $info{"GT"} eq "0|1");
	$info{"BX"}=~s/-[^;|^,]*//g;
	my @barcode=split /,/,$info{"BX"};
	next unless (defined $barcode[0] and defined $barcode[1]);
	if($line[0] eq $site[0] and $line[1]>=$site[-3] and  $line[1]<=$site[-2] and $mark==0){
                if($info{"GT"} eq "0|1"){
                       push @seq3,$barcode[0];
                       push @seq4,$barcode[1];
                }
                elsif($info{"GT"} eq "1|0"){
                       push @seq3,$barcode[1];
                       push @seq4,$barcode[0];
                }
               	my $match=&test(\@seq1,\@seq3)+&test(\@seq2,\@seq4);
                my $unmatch=&test(\@seq1,\@seq4)+&test(\@seq2,\@seq3);
		my $pos;
		if($line[1]>=$site[-3] and $line[1]<=$site[-2]){
			$pos="*$line[0]:$line[1]";
		}
		else{
			$pos="-";
		}
		if($match>=3 and $match/($match+$unmatch)>=0.8){
			push @out,"yes$pos";
			$skip=0;
		}
		elsif($unmatch>=3 and $unmatch/($match+$unmatch)>=0.8){
			push @out,"error$pos";
			$skip=1;
		}
		else{
			push @out,"no$pos";
			$skip=1;
		}
		@seq3=();
                @seq4=();
        }
	if($line[0] eq $site[0] and $line[1]>$site[-2] and $mark==0){
		if($info{"GT"} eq "0|1"){
                       push @seq3,$barcode[0];
                       push @seq4,$barcode[1];
                }
                elsif($info{"GT"} eq "1|0"){
                       push @seq3,$barcode[1];
                       push @seq4,$barcode[0];
                }
                if($#seq3>=2){
                        my $match=&test(\@seq1,\@seq3)+&test(\@seq2,\@seq4);
                        my $unmatch=&test(\@seq1,\@seq4)+&test(\@seq2,\@seq3);
			print join "\t",@site;
			print "\t$match\t$unmatch\t";
			if($#out>=0){
				print join ",",@out;
			}else{
				print "no";
			}
			print "\n";
			@out=();
	                $mark=1;
			$skip=0;
			@seq1=@seq3;
			@seq2=@seq4;
			@seq3=();
			@seq4=();
		}
		$skip=1;
	}
	if($mark==1 and !eof($file_h)){
		$site=<$file_h>;
		chomp $site;
		@site=split /\t/,$site;
		$mark=0;
	}
	if($skip==0){
		if($#seq1>=2){
	                shift @seq1;
        	        shift @seq2;
	        }
		if($info{"GT"} eq "0|1"){
       		        push @seq1,$barcode[0];
       	       		push @seq2,$barcode[1];
		}
	        elsif($info{"GT"} eq "1|0"){
	      		push @seq1,$barcode[1];
	       	        push @seq2,$barcode[0];
	        }
	}
}
close $file_h;
close $vcf_h;

sub test{
	my ($a,$b)=@_;
	my $count=0;
	my (@c,@d);
	foreach (0..$#$a){
		my @cont=split /;/,$$a[$_];
		push @c,@cont;
	}
	foreach (0..$#$b){
                my @cont=split /;/,$$b[$_];
                push @d,@cont;
        }
	foreach my $m (0..$#c){
		foreach my $n (0..$#d){
			if($c[$m] eq $d[$n]){
			$count++;
			}
		}
	}
	return $count;
}


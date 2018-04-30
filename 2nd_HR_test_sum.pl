#!/usr/bin/perl -w 
#
use strict;

my $file1=shift or die "Usage: $0 <2nd_F_C_HR_test_F> <2nd_F_C_HR_test_C>\n";
my $file2=shift or die "Usage: $0 <2nd_F_C_HR_test_F> <2nd_F_C_HR_test_C>\n";

my %info;
open my $file1_h,'<',$file1;
while(<$file1_h>){
	my @line=split;
	my $sym;
	if($line[-1]=~/error/){
		$sym="error";
	}elsif($line[-3]>=3 && $line[-3]/($line[-3]+$line[-2])>0.75){
		$sym="yes";
	}elsif($line[-1]=~/error_like/){
                $sym="error_like";
        }else{
		$sym="no";
	}
	my $value="$line[-3]\t$line[-2]";
	pop @line;
	pop @line;
	pop @line;
	my $id = join "\t",@line;
	$info{$id}="$value\t$sym\t-\t-\t-";
}
close $file1_h;

open my $file2_h,'<',$file2;
while(<$file2_h>){
	my @line=split;
        my $sym;
        if($line[-1]=~/error/){
                $sym="error";
        }elsif($line[-3]>=3 && $line[-3]/($line[-3]+$line[-2])>0.75){
                $sym="yes";
        }elsif($line[-1]=~/error_like/){
                $sym="error_like";
        }else{
                $sym="no";
        }
        my $value="$line[-3]\t$line[-2]";
        pop @line;
	pop @line;
        pop @line;
        my $id = join "\t",@line;
	if(exists $info{$id}){
		$info{$id}=~s/\t-\t-\t-/\t$value\t$sym/;	
	}
	else{
		$info{$id}="-\t-\t-\t$value\t$sym";
	}
}
close $file2_h;

foreach my $id (keys %info){
	my @value=split /\t/,$info{$id};
	if($value[2] eq "error" or $value[5] eq "error"){
		print "$id\t$info{$id}\tswitch_error\n";
	}
	elsif($value[2] eq "yes" and ($value[5] eq "yes" or $value[5] eq "no")){
		print "$id\t$info{$id}\thigh_conf\n";
	}
	else{
		print "$id\t$info{$id}\tlow_conf\n";
	}
}



#!/usr/bin/perl -w 
#get phase set block of child genome;
use strict;
my $haplo=shift or die "Usage: $0 <1st_haplo_filter> \n";

&barcode(6);

sub barcode {
	my ($n)=@_;
	open my $haplo_h,'<',$haplo;
	my $id;
	my $end;
	while(<$haplo_h>){
	        my @line=split;
	        next if $line[$n]=~/^0\|0;/;
	        next if $line[$n]=~/^[^;]*;-1*;/;
		my @cont=split /;/,$line[$n];
	        unless(defined($id)){
	                $id="$line[0]\t$cont[1]";
	                $end=$line[1];
	                next;
	        }
	        my $name="$line[0]\t$cont[1]";
	        if ($name ne $id){
	                print "$id\t$end\n";
	        }
	        $id="$line[0]\t$cont[1]";
	        $end=$line[1];
	}
	if(eof($haplo_h)){
	        print "$id\t$end\n";
	}
	close $haplo_h;
}

#!/usr/bin/perl -w
#
use strict;

my $file=shift or die "Usage: $0 <haplotype_block_match.file>\n";

&test_file($file,11,12,"$file.10k.tmp");
&stat("$file.10k.tmp");

sub test_file{
my ($file,$n,$m,$out)=@_;
my $gender;
if($file=~/_(\w)_C/){
	$gender=$1;
}
my ($start,$end);
my $block;
my $chr;
my ($o_o_m,$o_t_m,$t_o_m,$t_t_m)=(0,0,0,0);
my ($o_o_u,$o_t_u,$t_o_u,$t_t_u)=(0,0,0,0);
open my $fileh,'<', $file;
open my $outh,'>', $out;
while(<$fileh>){
	chomp;
	my @line=split;
	next if ($line[$n]eq"." or $line[$m]eq".");
	if(!defined($start)){
		$start=$line[$n];
		$end=$line[$m];
		$chr=$line[0];
		$block="$line[8]\t$line[9]";
		my($a,$b,$c,$d,$e,$f,$g,$h)=&count(@line);
		($o_o_m,$o_t_m,$t_o_m,$t_t_m,$o_o_u,$o_t_u,$t_o_u,$t_t_u)=($o_o_m+$a,$o_t_m+$b,$t_o_m+$c,$t_t_m+$d,$o_o_u+$e,$o_t_u+$f,$t_o_u+$g,$t_t_u+$h);
	}
	else{
		if($line[0]eq$chr and $line[$n]eq$start and $line[$m]eq$end){
			my($a,$b,$c,$d,$e,$f,$g,$h)=&count(@line);
	                ($o_o_m,$o_t_m,$t_o_m,$t_t_m,$o_o_u,$o_t_u,$t_o_u,$t_t_u)=($o_o_m+$a,$o_t_m+$b,$t_o_m+$c,$t_t_m+$d,$o_o_u+$e,$o_t_u+$f,$t_o_u+$g,$t_t_u+$h);
		}else{
			my $sum=$o_o_m+$o_o_u;
			print $outh "$chr\t$start\t$end\t$block\t";
			print $outh "1-1:".$o_o_m.";".$o_o_u."\t";
			print $outh "1-2:".$o_t_m.";".$o_t_u."\t";
			print $outh "2-1:".$t_o_m.";".$t_o_u."\t";
			print $outh "2-2:".$t_t_m.";".$t_t_u."\t";
			#Father-son:1-1 or 2-1;Mother-son:1-2 or 2-2;change the rest into zero;
                        if($gender eq "F"){
                                $o_t_m=0;$o_t_u=0;
                                $t_t_m=0;$t_t_u=0;
                        }elsif($gender eq "M"){
                                $o_o_m=0;$o_o_u=0;
                                $t_o_m=0;$t_o_u=0;
                        }
			printf $outh "%.3f\t%.3f\t%.3f\t%.3f\n",$o_o_m/$sum,$o_t_m/$sum,$t_o_m/$sum,$t_t_m/$sum;
			$start=$line[$n];
	                $end=$line[$m];
               		$chr=$line[0];
			$block="$line[8]\t$line[9]";
			($o_o_m,$o_t_m,$t_o_m,$t_t_m)=(0,0,0,0);
			($o_o_u,$o_t_u,$t_o_u,$t_t_u)=(0,0,0,0);
			my($a,$b,$c,$d,$e,$f,$g,$h)=&count(@line);
	                ($o_o_m,$o_t_m,$t_o_m,$t_t_m,$o_o_u,$o_t_u,$t_o_u,$t_t_u)=($o_o_m+$a,$o_t_m+$b,$t_o_m+$c,$t_t_m+$d,$o_o_u+$e,$o_t_u+$f,$t_o_u+$g,$t_t_u+$h);
		}

	}

}
if(eof($fileh)){
	my $sum=$o_o_m+$o_o_u;
	print $outh "$chr\t$start\t$end\t$block\t";
	print $outh "1-1:".$o_o_m.";".$o_o_u."\t";
	print $outh "1-2:".$o_t_m.";".$o_t_u."\t";
	print $outh "2-1:".$t_o_m.";".$t_o_u."\t";
	print $outh "2-2:".$t_t_m.";".$t_t_u."\t";
	#Father-son:1-1 or 2-1;Mother-son:1-2 or 2-2;change the rest into zero;
        if($gender eq "F"){
               $o_t_m=0;$o_t_u=0;
               $t_t_m=0;$t_t_u=0;
        }elsif($gender eq "M"){
               $o_o_m=0;$o_o_u=0;
               $t_o_m=0;$t_o_u=0;
        }
	printf $outh "%.3f\t%.3f\t%.3f\t%.3f\n",$o_o_m/$sum,$o_t_m/$sum,$t_o_m/$sum,$t_t_m/$sum;
}
close $fileh;
close $outh;
}

sub count{
	my @line=@_;
	my ($o_o_m,$o_t_m,$t_o_m,$t_t_m,$o_o_u,$o_t_u,$t_o_u,$t_t_u)=(0,0,0,0,0,0,0,0);
	if($line[4]eq"1-1"){
		$o_o_m++;
	}elsif($line[4]eq"0-0"){
		$o_o_u++;
	}
	if($line[5]eq"1-2"){
                $o_t_m++;
        }elsif($line[5]eq"0-0"){
                $o_t_u++;
        }
	if($line[6]eq"2-1"){
                $t_o_m++;
        }elsif($line[6]eq"0-0"){
                $t_o_u++;
        }
	if($line[7]eq"2-2"){
                $t_t_m++;
        }elsif($line[7]eq"0-0"){
                $t_t_u++;
        }
	return ($o_o_m,$o_t_m,$t_o_m,$t_t_m,$o_o_u,$o_t_u,$t_o_u,$t_t_u);
}

sub stat{
my ($file,$out)=@_;
open my $fileh,'<',$file;
while(<$fileh>){
        my @line=split;
        my @num=($#line-3)..$#line;
        my %info;
        my @array=($line[$#line-3],$line[$#line-2],$line[$#line-1],$line[$#line]);
        @array=sort {$b<=>$a} @array;
        foreach my $n (0..$#array){
                        foreach my $i (@num){
                                if($line[$i] == $array[$n]){
                                        $info{$n+1}=$i;
                                        if(grep {$_ ne $i} @num){
                                                @num=grep {$_ != $i} @num;
                                        }
                                        last;
                                }
                        }
        }
	my $num;
	if($line[$info{1}-4]=~/\d-\d:(\d*);/){
		$num=$1;
	}
        if($num >=1 and $line[$info{1}]>0.6 and ($line[$info{1}]-$line[$info{2}])>0.2){
		print "$line[0]\t$line[1]\t$line[2]\t$line[3]\t$line[4]\t$line[$info{1}-4]\t$line[$info{2}-4]\t$line[$info{3}-4]\t$line[$info{4}-4]\t$line[$info{1}]\t$line[$info{2}]\t$line[$info{3}]\t$line[$info{4}]\t$line[$info{1}-4]\n";
	}
        else{
                print "$line[0]\t$line[1]\t$line[2]\t$line[3]\t$line[4]\t$line[$info{1}-4]\t$line[$info{2}-4]\t$line[$info{3}-4]\t$line[$info{4}-4]\t$line[$info{1}]\t$line[$info{2}]\t$line[$info{3}]\t$line[$info{4}]\t-\n";
        }
}
close $fileh;
}
 `rm *.tmp`;

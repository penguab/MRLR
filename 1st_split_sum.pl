#!/usr/bin/perl -w
#
use strict;

my $file=shift or die "Usage: $0 <haplotype_block_match.file>\n";

&test_file($file,13,14,"$file.10k.tmp");
&stat("$file.10k.tmp");

sub test_file{
my ($file,$n,$m,$out)=@_;
my ($start,$end)=(0,0);
my $block;
my $chr;
my ($o_o_m,$o_t_m,$t_o_m,$t_t_m)=(0,0,0,0); #$o_o_m:one-one-match;$o_t_m:one-two-match
my ($o_o_u,$o_t_u,$t_o_u,$t_t_u)=(0,0,0,0); #$o_o_u:one-one-unmatch;$o_t_u:one-two-unmatch
open my $fileh,'<', $file;
open my $outh,'>', $out;
while(<$fileh>){
	my @line=split;
	next if ($line[$n]eq"." or $line[$m]eq".");
	if($start==0){
		$start=$line[$n];
		$end=$line[$m];
		$chr=$line[0];
		$block="$line[10]\t$line[11]";
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
			printf $outh "%.3f\t%.3f\t%.3f\t%.3f\n",$o_o_m/$sum,$o_t_m/$sum,$t_o_m/$sum,$t_t_m/$sum;
			$start=$line[$n];
	                $end=$line[$m];
               		$chr=$line[0];
			$block="$line[10]\t$line[11]";
			($o_o_m,$o_t_m,$t_o_m,$t_t_m)=(0,0,0,0);
			($o_o_u,$o_t_u,$t_o_u,$t_t_u)=(0,0,0,0);
			my($a,$b,$c,$d,$e,$f,$g,$h)=&count(@line);
	                ($o_o_m,$o_t_m,$t_o_m,$t_t_m,$o_o_u,$o_t_u,$t_o_u,$t_t_u)=($o_o_m+$a,$o_t_m+$b,$t_o_m+$c,$t_t_m+$d,$o_o_u+$e,$o_t_u+$f,$t_o_u+$g,$t_t_u+$h);
		}

	}

}
if(eof($fileh)){
	my $sum=$o_o_m+$o_o_u;
	print $outh "$chr\t$start\t$end\t";
	print $outh "1-1:".$o_o_m.";".$o_o_u."\t";
	print $outh "1-2:".$o_t_m.";".$o_t_u."\t";
	print $outh "2-1:".$t_o_m.";".$t_o_u."\t";
	print $outh "2-2:".$t_t_m.";".$t_t_u."\t";
	printf $outh "%.3f\t%.3f\t%.3f\t%.3f\n",$o_o_m/$sum,$o_t_m/$sum,$t_o_m/$sum,$t_t_m/$sum;
}
close $fileh;
close $outh;
}

sub count{
	my @line=@_;
	my ($o_o_m,$o_t_m,$t_o_m,$t_t_m,$o_o_u,$o_t_u,$t_o_u,$t_t_u)=(0,0,0,0,0,0,0,0);
	if($line[6]eq"1-1"){
		$o_o_m++;
	}elsif($line[6]eq"0-0"){
		$o_o_u++;
	}
	if($line[7]eq"1-2"){
                $o_t_m++;
        }elsif($line[7]eq"0-0"){
                $o_t_u++;
        }
	if($line[8]eq"2-1"){
                $t_o_m++;
        }elsif($line[8]eq"0-0"){
                $t_o_u++;
        }
	if($line[9]eq"2-2"){
                $t_t_m++;
        }elsif($line[9]eq"0-0"){
                $t_t_u++;
        }
	return ($o_o_m,$o_t_m,$t_o_m,$t_t_m,$o_o_u,$o_t_u,$t_o_u,$t_t_u);
}

sub stat{
my ($file)=@_;
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
                                        if(grep {$_ != $i} @num){
                                                @num=grep {$_ != $i} @num;
                                        }
                                        last;
                                }
                        }
        }
	my ($num1,$num2,$num3,$id1,$id2,$id3);
	if($line[$info{1}-4]=~/\d-(\d):(\d*);/){
		$id1=$1;
		$num1=$2;
	}
	if($line[$info{2}-4]=~/\d-(\d):(\d*);/){
                $id2=$1;
		$num2=$2;
        }
	if($line[$info{3}-4]=~/\d-(\d):(\d*);/){
                $id3=$1;
                $num3=$2;
        }
        if($num1-$num2 >=1 and $line[$info{1}]>0.6 and ($line[$info{1}]-$line[$info{2}])>0.1){
		print "$line[0]\t$line[1]\t$line[2]\t$line[3]\t$line[4]\t$line[$info{1}-4]\t$line[$info{2}-4]\t$line[$info{3}-4]\t$line[$info{4}-4]\t$line[$info{1}]\t$line[$info{2}]\t$line[$info{3}]\t$line[$info{4}]\t$line[$info{1}-4]\n";
	}elsif($num2-$num3 >=1 and $line[$info{2}]>0.6 and ($line[$info{1}]-$line[$info{2}])<=0.1 and $id1 eq $id2 and ($line[$info{1}]-$line[$info{3}])>0.1){
		print "$line[0]\t$line[1]\t$line[2]\t$line[3]\t$line[4]\t$line[$info{1}-4]\t$line[$info{2}-4]\t$line[$info{3}-4]\t$line[$info{4}-4]\t$line[$info{1}]\t$line[$info{2}]\t$line[$info{3}]\t$line[$info{4}]\t","0-$id1\n";
        }else{
                print "$line[0]\t$line[1]\t$line[2]\t$line[3]\t$line[4]\t$line[$info{1}-4]\t$line[$info{2}-4]\t$line[$info{3}-4]\t$line[$info{4}-4]\t$line[$info{1}]\t$line[$info{2}]\t$line[$info{3}]\t$line[$info{4}]\t-\n";
        }
}
close $fileh;
}
`rm *.tmp`;

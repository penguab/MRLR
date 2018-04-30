#!/usr/bin/bash
#

if [ $# != 4 ]; then
	echo $0 \<Father_vcf\> \<Mother_vcf\> \<Child_vcf\> \<output_profix\>
	exit 1
fi

father=`readlink -f $1`
mother=`readlink -f $2`
child=`readlink -f $3`
Sample=$4

if [ -d ${Sample}_out ]; then
	echo -e "Folder exists; Use a different name\n" && exit 1; else
	mkdir ${Sample}_out && cd ${Sample}_out
fi

echo -e "This is the pipeline for identification of meiotic recombination events using trio samples of 10x genomics longranger vcf outputs\n\nWe assume the script directory and Bedtools were added in path environment\n\n"
echo "Program starts!"
echo "collect haplotype information"

1st_haplotype.pl ${father} ${mother}  ${child} > 1st_${Sample}_haplo
sort -k1,1 -k2,2n 1st_${Sample}_haplo >1st_${Sample}_haplo_sort
1st_haplotype_mask.pl 1st_${Sample}_haplo_sort >1st_${Sample}_haplo_sort_mask
1st_haplotype_mutation_rm.pl 1st_${Sample}_haplo_sort_mask >1st_${Sample}_haplo_mutation_rm

echo "first round: phase child genome"
1st_haplotype_filter.pl 1st_${Sample}_haplo_mutation_rm >1st_${Sample}_haplo_filter
1st_child_barcode.pl 1st_${Sample}_haplo_filter >1st_${Sample}_C_barcode
perl -lane '$len=$F[2]-$F[1];if($len>=9999){print "$F[0]\t$F[1]\t$F[2]\t$len"}' 1st_${Sample}_C_barcode >1st_${Sample}_C_barcode.10k

haplotype_group_filter.pl 1st_${Sample}_haplo_filter F >1st_${Sample}_F_C_haplo
parent_child_match.pl 1st_${Sample}_F_C_haplo 1st_${Sample}_C_barcode.10k >1st_${Sample}_F_C_match
parent_child_match_split.pl 1st_${Sample}_F_C_match >1st_${Sample}_F_C_match_split
1st_split_sum.pl 1st_${Sample}_F_C_match_split >1st_${Sample}_F_C_split_sum

haplotype_group_filter.pl 1st_${Sample}_haplo_filter M >1st_${Sample}_M_C_haplo
parent_child_match.pl 1st_${Sample}_M_C_haplo 1st_${Sample}_C_barcode.10k >1st_${Sample}_M_C_match
parent_child_match_split.pl 1st_${Sample}_M_C_match >1st_${Sample}_M_C_match_split
1st_split_sum.pl 1st_${Sample}_M_C_match_split >1st_${Sample}_M_C_split_sum

echo "first round: reshuffle child genome"
bedtools window -a 1st_${Sample}_F_C_split_sum -b 1st_${Sample}_M_C_split_sum -w 0 >1st_${Sample}_split_merge
1st_split_merge_sum.pl 1st_${Sample}_split_merge >1st_${Sample}_split_merge_sum
1st_merge_sum_stat.pl 1st_${Sample}_split_merge_sum >1st_${Sample}_split_merge_sum_stat

2nd_haplotype_shuffle.pl 1st_${Sample}_split_merge_sum_stat 1st_${Sample}_haplo_mutation_rm >2nd_${Sample}_haplo_shuffle

echo "second round: detect meiotic recombination in father"
haplotype_group_filter.pl 2nd_${Sample}_haplo_shuffle F >2nd_${Sample}_F_C_haplo
2nd_parent_child_phase_block.pl 2nd_${Sample}_F_C_haplo >2nd_${Sample}_F_C_block
perl -lane 'print if $F[3]>10000' 2nd_${Sample}_F_C_block >2nd_${Sample}_F_C_block.10k
parent_child_match.pl 2nd_${Sample}_F_C_haplo 2nd_${Sample}_F_C_block.10k >2nd_${Sample}_F_C_match
parent_child_match_split.pl 2nd_${Sample}_F_C_match >2nd_${Sample}_F_C_match_split
2nd_split_sum.pl 2nd_${Sample}_F_C_match_split >2nd_${Sample}_F_C_split_sum

2nd_split_sum_stat.pl 2nd_${Sample}_F_C_split_sum >2nd_${Sample}_F_C_split_sum_stat
2nd_HR.pl 2nd_${Sample}_F_C_split_sum_stat >2nd_${Sample}_F_C_HR
HR_site.pl 2nd_${Sample}_F_C_HR 2nd_${Sample}_F_C_match_split >2nd_${Sample}_F_C_HR_site
HR_test.pl 2nd_${Sample}_F_C_HR_site ${father} >2nd_${Sample}_F_C_HR_test_F
HR_test.pl 2nd_${Sample}_F_C_HR_site ${child} >2nd_${Sample}_F_C_HR_test_C
2nd_HR_test_sum.pl 2nd_${Sample}_F_C_HR_test_F 2nd_${Sample}_F_C_HR_test_C |sort -k1,1 -k6,6n >final_${Sample}_F_C_HR_test_sum

echo "second round: detect meiotic recombination in mother"
haplotype_group_filter.pl 2nd_${Sample}_haplo_shuffle M >2nd_${Sample}_M_C_haplo
2nd_parent_child_phase_block.pl 2nd_${Sample}_M_C_haplo >2nd_${Sample}_M_C_block
perl -lane 'print if $F[3]>10000' 2nd_${Sample}_M_C_block >2nd_${Sample}_M_C_block.10k
parent_child_match.pl 2nd_${Sample}_M_C_haplo 2nd_${Sample}_M_C_block.10k >2nd_${Sample}_M_C_match
parent_child_match_split.pl 2nd_${Sample}_M_C_match >2nd_${Sample}_M_C_match_split
2nd_split_sum.pl 2nd_${Sample}_M_C_match_split >2nd_${Sample}_M_C_split_sum

2nd_split_sum_stat.pl 2nd_${Sample}_M_C_split_sum >2nd_${Sample}_M_C_split_sum_stat
2nd_HR.pl 2nd_${Sample}_M_C_split_sum_stat >2nd_${Sample}_M_C_HR
HR_site.pl 2nd_${Sample}_M_C_HR 2nd_${Sample}_M_C_match_split >2nd_${Sample}_M_C_HR_site
HR_test.pl 2nd_${Sample}_M_C_HR_site ${mother} >2nd_${Sample}_M_C_HR_test_M
HR_test.pl 2nd_${Sample}_M_C_HR_site ${child} >2nd_${Sample}_M_C_HR_test_C
2nd_HR_test_sum.pl 2nd_${Sample}_M_C_HR_test_M 2nd_${Sample}_M_C_HR_test_C |sort -k1,1 -k6,6n >final_${Sample}_M_C_HR_test_sum

echo -e "finished\n\n\n"

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

if [ -d trio_${Sample} ]; then
        echo -e "Folder exists; Use a different name\n" && exit 1; else
        mkdir trio_${Sample} && cd trio_${Sample}
fi

echo -e "\n\nThis is the pipeline for identification of meiotic recombination events using trio samples of 10x genomics longranger vcf outputs\n\nWe assume the script directory and Bedtools were added in path environment\n\n"
echo "Program starts!"
echo "collect haplotype information"

1st_haplotype.pl $father $mother  $child > 1st_${Sample}_haplo
sort -k1,1 -k2,2n 1st_${Sample}_haplo >1st_${Sample}_haplo_sort
1st_haplotype_mask.pl 1st_${Sample}_haplo_sort >1st_${Sample}_haplo_sort_mask
1st_haplotype_mutation_rm.pl 1st_${Sample}_haplo_sort_mask >1st_${Sample}_haplo_mutation_rm

echo "first round: phase child genome"
1st_haplotype_filter.pl 1st_${Sample}_haplo_mutation_rm >1st_${Sample}_haplo_filter
1st_child_barcode.pl 1st_${Sample}_haplo_filter >1st_${Sample}_C_barcode
perl -lane '$len=$F[2]-$F[1];if($len>=9999){print "$F[0]\t$F[1]\t$F[2]\t$len"}' 1st_${Sample}_C_barcode >1st_${Sample}_C_barcode.10k

1st_haplotype_group_filter.pl 1st_${Sample}_haplo_filter F >1st_${Sample}_F_C_haplo
1st_parent_child_match.pl 1st_${Sample}_F_C_haplo 1st_${Sample}_C_barcode.10k >1st_${Sample}_F_C_match
1st_parent_child_match_split.pl 1st_${Sample}_F_C_match >1st_${Sample}_F_C_match_split
1st_split_sum.pl 1st_${Sample}_F_C_match_split >1st_${Sample}_F_C_split_sum

1st_haplotype_group_filter.pl 1st_${Sample}_haplo_filter M >1st_${Sample}_M_C_haplo
1st_parent_child_match.pl 1st_${Sample}_M_C_haplo 1st_${Sample}_C_barcode.10k >1st_${Sample}_M_C_match
1st_parent_child_match_split.pl 1st_${Sample}_M_C_match >1st_${Sample}_M_C_match_split
1st_split_sum.pl 1st_${Sample}_M_C_match_split >1st_${Sample}_M_C_split_sum

echo "first round: reshuffle child genome"
bedtools window -a 1st_${Sample}_F_C_split_sum -b 1st_${Sample}_M_C_split_sum -w 0 >1st_${Sample}_split_merge
1st_split_merge_sum.pl 1st_${Sample}_split_merge >1st_${Sample}_split_merge_sum
1st_merge_sum_stat.pl 1st_${Sample}_split_merge_sum >1st_${Sample}_split_merge_sum_stat
2nd_haplotype_shuffle.pl 1st_${Sample}_split_merge_sum_stat 1st_${Sample}_haplo_filter >2nd_${Sample}_haplo_shuffle

echo "second round: detect meiotic recombination in father"
1st_haplotype_group_filter.pl 2nd_${Sample}_haplo_shuffle F >2nd_${Sample}_F_C_haplo
2nd_parent_child_phase_block.pl 2nd_${Sample}_F_C_haplo >2nd_${Sample}_F_C_block
perl -lane 'print if $F[3]>10000' 2nd_${Sample}_F_C_block >2nd_${Sample}_F_C_block.10k
2nd_parent_child_match.pl 2nd_${Sample}_F_C_haplo 2nd_${Sample}_F_C_block.10k >2nd_${Sample}_F_C_match
2nd_match_sum.pl 2nd_${Sample}_F_C_match >2nd_${Sample}_F_C_match_sum
2nd_match_sum_stat.pl 2nd_${Sample}_F_C_match_sum >2nd_${Sample}_F_C_match_sum_stat

2nd_HR.pl 2nd_${Sample}_F_C_match_sum_stat >2nd_${Sample}_F_C_HR
2nd_HR_test.pl 2nd_${Sample}_F_C_HR $father >2nd_${Sample}_F_C_HR_test_F
2nd_HR_test.pl 2nd_${Sample}_F_C_HR $child >2nd_${Sample}_F_C_HR_test_C
2nd_test_sum.pl 2nd_${Sample}_F_C_HR_test_F 2nd_${Sample}_F_C_HR_test_C >2nd_${Sample}_F_C_HR_test_sum

echo "second round: detect meiotic recombination in mother"
1st_haplotype_group_filter.pl 2nd_${Sample}_haplo_shuffle M >2nd_${Sample}_M_C_haplo
2nd_parent_child_phase_block.pl 2nd_${Sample}_M_C_haplo >2nd_${Sample}_M_C_block
perl -lane 'print if $F[3]>10000' 2nd_${Sample}_M_C_block >2nd_${Sample}_M_C_block.10k
2nd_parent_child_match.pl 2nd_${Sample}_M_C_haplo 2nd_${Sample}_M_C_block.10k >2nd_${Sample}_M_C_match
2nd_match_sum.pl 2nd_${Sample}_M_C_match >2nd_${Sample}_M_C_match_sum
2nd_match_sum_stat.pl 2nd_${Sample}_M_C_match_sum >2nd_${Sample}_M_C_match_sum_stat

2nd_HR.pl 2nd_${Sample}_M_C_match_sum_stat >2nd_${Sample}_M_C_HR
2nd_HR_test.pl 2nd_${Sample}_M_C_HR $mother >2nd_${Sample}_M_C_HR_test_M
2nd_HR_test.pl 2nd_${Sample}_M_C_HR $child >2nd_${Sample}_M_C_HR_test_C
2nd_test_sum.pl 2nd_${Sample}_M_C_HR_test_M 2nd_${Sample}_M_C_HR_test_C >2nd_${Sample}_M_C_HR_test_sum

2nd_parameter.pl 2nd_${Sample}_F_C_HR_test_sum |sort -k1,1 -k2,2n >final_${Sample}_F_C_sum
2nd_parameter.pl 2nd_${Sample}_M_C_HR_test_sum |sort -k1,1 -k2,2n >final_${Sample}_M_C_sum

mkdir tmp.files |mv 1st* tmp.files | mv 2nd* tmp.files

echo -e "finished\n\n\n"

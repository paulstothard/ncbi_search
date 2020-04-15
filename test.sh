#!/bin/bash
set -e
if [ ! -d test_output ]; then
    mkdir test_output
fi

perl ncbi_search.pl -q 'leptin AND homo sapiens[ORGN]' \
        -o test_output/results1.txt -d protein -r fasta -m 10 -v

perl ncbi_search.pl -q 'dysphagia AND homo sapiens[ORGN]' \
        -o test_output/results2.txt -d pubmed -r uilist -m 10 -v

#gp is for GenPept
perl ncbi_search.pl -q telomere -o test_output/results3.txt -d protein -r gp \
        -m 5 -v

#gb is for GenBank
perl ncbi_search.pl -q telomere -o test_output/results3.txt -d nucleotide \
        -r gb -m 5 -v

#compare new output to sample output
new_output=test_output
old_output=sample_output
new_files=($( find $new_output -type f -print0 | \
        perl -ne 'my @files = split(/\0/, $_); foreach(@files) { if (!($_ =~ m/\.svn/)) {print "$_\n";}}'))
for (( i=0; i<${#new_files[@]}; i++ ));
do
    old_file=${old_output}`echo "${new_files[$i]}" \
            | perl -nl -e 's/^[^\/]+//;' -e 'print $_'`
    echo "Comparing ${old_file} to ${new_files[$i]}"
    set +e
    diff -u $old_file ${new_files[$i]}
    if [ $? -eq 0 ]; then
      echo "No differences found"
    fi
    set -e
done

#!/usr/bin/env bash
set -ex

outdir=test_output/

if [ ! -d $outdir ]; then
  mkdir "$outdir"
fi

perl ncbi_search.pl -q 'NC_045512[Accession]' \
-o "$outdir"NC_045512.gbk \
-d nuccore \
-r gbwithparts \
-v

perl ncbi_search.pl -q 'NC_012920.1[Accession]' \
-o "$outdir"AL513382.1.faa \
-d nuccore \
-r fasta_cds_aa \
-v

perl ncbi_search.pl -q 'NC_009925:NC_009934[Accession]' \
-o "$outdir"outdir \
-d nuccore \
-r gbwithparts \
-s \
-v

perl ncbi_search.pl -q 'coronavirus[Organism] AND nucleotide genome[Filter] AND refseq[Filter]' \
-o "$outdir"outdir2 \
-d nuccore \
-r gbwithparts \
-m 5 \
-s \
-v

perl ncbi_search.pl -q 'Stothard P[Author]' \
-o "$outdir"abstracts.txt \
-d pubmed \
-r abstract \
-m 5 \
-v

perl ncbi_search.pl -q 'homo sapiens[Organism] AND 17[Chromosome] AND 7614064:7833711[Base position] AND GRCh38.p13[Assembly name]' \
-o "$outdir"gene_list.txt \
-d gene \
-r gene_table \
-v

perl ncbi_search.pl -q 'homo sapiens[Organism] AND PRNP[Gene name]' \
-o "$outdir"gene_info.txt \
-d gene \
-v

perl ncbi_search.pl -q '17[Chromosome] AND 7614064:7620000[Base Position]' \
-o "$outdir"clinvar_info.xml \
-d clinvar \
-r clinvarset \
-v

printf 'NP_776246.1\nNP_001073369.1\nNP_995328.2\n' \
> "$outdir"accessions.txt

< "$outdir"accessions.txt xargs -t -I{} \
perl ncbi_search.pl -q '{}[Accession]' \
-o "$outdir"{}.fasta \
-d protein \
-r fasta \
-v

perl ncbi_search.pl -q 'coronavirus[Organism] AND nucleotide genome[Filter] AND refseq[Filter]' \
-o "$outdir"sequences.fasta \
-d nuccore \
-r fasta \
-m 5 \
-v

#create separate file for each sequence
outputdir="$outdir"sequences/
mkdir -p "$outputdir"
awk '/^>/ {OUT=substr($0,2); split(OUT, a, " "); sub(/[^A-Za-z_0-9\.\-]/, "", a[1]); OUT = "'"$outputdir"'" a[1] ".fa"}; OUT {print >>OUT; close(OUT)}' \
"$outdir"sequences.fasta

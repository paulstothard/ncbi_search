#!/usr/bin/env bash
# Test suite for ncbi_search.pl
# Runs multiple queries and validates outputs

set -e # Exit on error
set -u # Exit on undefined variable

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Counters
TESTS_PASSED=0
TESTS_FAILED=0
TESTS_TOTAL=0

outdir=test_output/

# Helper functions
print_header() {
  echo -e "\n${BLUE}========================================${NC}"
  echo -e "${BLUE}$1${NC}"
  echo -e "${BLUE}========================================${NC}"
}

print_test() {
  TESTS_TOTAL=$((TESTS_TOTAL + 1))
  echo -e "\n${YELLOW}[Test $TESTS_TOTAL]${NC} $1"
}

validate_file() {
  local file=$1
  local min_size=${2:-1} # Default minimum size is 1 byte

  if [[ ! -f "$file" ]]; then
    echo -e "${RED}✗ FAIL${NC} - File not found: $file"
    TESTS_FAILED=$((TESTS_FAILED + 1))
    return 1
  fi

  local size=$(stat -f%z "$file" 2>/dev/null || stat -c%s "$file" 2>/dev/null || echo 0)
  if [[ $size -lt $min_size ]]; then
    echo -e "${RED}✗ FAIL${NC} - File too small ($size bytes): $file"
    TESTS_FAILED=$((TESTS_FAILED + 1))
    return 1
  fi

  echo -e "${GREEN}✓ PASS${NC} - Created $file ($size bytes)"
  TESTS_PASSED=$((TESTS_PASSED + 1))
  return 0
}

validate_dir() {
  local dir=$1
  local min_files=${2:-1}

  if [[ ! -d "$dir" ]]; then
    echo -e "${RED}✗ FAIL${NC} - Directory not found: $dir"
    TESTS_FAILED=$((TESTS_FAILED + 1))
    return 1
  fi

  local count=$(find "$dir" -type f | wc -l | tr -d ' ')
  if [[ $count -lt $min_files ]]; then
    echo -e "${RED}✗ FAIL${NC} - Directory has only $count files (expected at least $min_files): $dir"
    TESTS_FAILED=$((TESTS_FAILED + 1))
    return 1
  fi

  echo -e "${GREEN}✓ PASS${NC} - Created $dir with $count files"
  TESTS_PASSED=$((TESTS_PASSED + 1))
  return 0
}

# Setup
print_header "Setting up test environment"
if [[ ! -d "$outdir" ]]; then
  mkdir -p "$outdir"
  echo "Created output directory: $outdir"
else
  echo "Using existing output directory: $outdir"
fi

# Test 1: Download genome in GenBank format
print_test "Download SARS-CoV-2 genome (NC_045512) in GenBank format"
perl ncbi_search.pl -q 'NC_045512[Accession]' \
  -o "${outdir}NC_045512.gbk" \
  -d nuccore \
  -r gbwithparts \
  -v
validate_file "${outdir}NC_045512.gbk" 50000

# Test 2: Extract CDS protein sequences
print_test "Extract CDS protein sequences from human mitochondrial genome"
perl ncbi_search.pl -q 'NC_012920.1[Accession]' \
  -o "${outdir}AL513382.1.faa" \
  -d nuccore \
  -r fasta_cds_aa \
  -v
validate_file "${outdir}AL513382.1.faa" 5000

# Test 3: Batch download with accession range
print_test "Download 10 genomes using accession range (NC_009925:NC_009934)"
perl ncbi_search.pl -q 'NC_009925:NC_009934[Accession]' \
  -o "${outdir}outdir" \
  -d nuccore \
  -r gbwithparts \
  -s \
  -v
validate_dir "${outdir}outdir" 10

# Test 4: Download limited records to separate files
print_test "Download 5 coronavirus genomes as separate files"
perl ncbi_search.pl -q 'coronavirus[Organism] AND nucleotide genome[Filter] AND refseq[Filter]' \
  -o "${outdir}outdir2" \
  -d nuccore \
  -r gbwithparts \
  -m 5 \
  -s \
  -v
validate_dir "${outdir}outdir2" 5

# Test 5: Download PubMed abstracts
print_test "Download 5 PubMed abstracts"
perl ncbi_search.pl -q 'Stothard P[Author]' \
  -o "${outdir}abstracts.txt" \
  -d pubmed \
  -r abstract \
  -m 5 \
  -v
validate_file "${outdir}abstracts.txt" 1000

# Test 6: Download PubMed abstracts with sorting
print_test "Download 5 PubMed abstracts sorted by publication date"
perl ncbi_search.pl -q 'Stothard P[Author]' \
  -o "${outdir}abstracts_sorted.txt" \
  -d pubmed \
  -r abstract \
  -m 5 \
  --sort pub_date \
  -v
validate_file "${outdir}abstracts_sorted.txt" 1000

# Test 7: Query gene database for genomic region
print_test "Find genes in chromosome 17 region (GRCh38.p13)"
perl ncbi_search.pl -q 'homo sapiens[Organism] AND 17[Chromosome] AND 7614064:7833711[Base position] AND GRCh38.p13[Assembly name]' \
  -o "${outdir}gene_list.txt" \
  -d gene \
  -r gene_table \
  -v
validate_file "${outdir}gene_list.txt" 100

# Test 8: Query gene database for specific gene
print_test "Get information about PRNP gene"
perl ncbi_search.pl -q 'homo sapiens[Organism] AND PRNP[Gene name]' \
  -o "${outdir}gene_info.txt" \
  -d gene \
  -v
validate_file "${outdir}gene_info.txt" 100

# Test 9: Query ClinVar database
print_test "Download ClinVar variants for chromosome 17 region"
perl ncbi_search.pl -q '17[Chromosome] AND 7614064:7620000[Base Position]' \
  -o "${outdir}clinvar_info.xml" \
  -d clinvar \
  -r clinvarset \
  -v
validate_file "${outdir}clinvar_info.xml" 50

# Test 10: Batch processing with accession file
print_test "Batch download protein sequences from accession list"
printf 'NP_776246.1\nNP_001073369.1\nNP_995328.2\n' \
  >"${outdir}accessions.txt"
validate_file "${outdir}accessions.txt" 10

xargs <"${outdir}accessions.txt" -t -I{} \
  perl ncbi_search.pl -q '{}[Accession]' \
  -o "${outdir}{}.fasta" \
  -d protein \
  -r fasta \
  -v

validate_file "${outdir}NP_776246.1.fasta" 100
validate_file "${outdir}NP_001073369.1.fasta" 100
validate_file "${outdir}NP_995328.2.fasta" 100

# Test 11: Download multi-sequence FASTA
print_test "Download 5 coronavirus sequences in FASTA format"
perl ncbi_search.pl -q 'coronavirus[Organism] AND nucleotide genome[Filter] AND refseq[Filter]' \
  -o "${outdir}sequences.fasta" \
  -d nuccore \
  -r fasta \
  -m 5 \
  -v
validate_file "${outdir}sequences.fasta" 50000

# Test 12: Split multi-sequence FASTA
print_test "Split multi-sequence FASTA into individual files"
outputdir="${outdir}sequences/"
mkdir -p "$outputdir"
awk '/^>/ {OUT=substr($0,2); split(OUT, a, " "); sub(/[^A-Za-z_0-9\.\-]/, "", a[1]); OUT = "'"$outputdir"'" a[1] ".fa"}; OUT {print >>OUT; close(OUT)}' \
  "${outdir}sequences.fasta"
validate_dir "${outdir}sequences" 5

# Summary
print_header "Test Summary"
echo -e "Test cases:     ${TESTS_TOTAL}"
echo -e "Validations:    ${TESTS_PASSED} passed, ${TESTS_FAILED} failed"
echo -e "Total checks:   $((TESTS_PASSED + TESTS_FAILED))"

if [[ $TESTS_FAILED -eq 0 ]]; then
  echo -e "\n${GREEN}All validations passed! ✓${NC}\n"
  exit 0
else
  echo -e "\n${RED}${TESTS_FAILED} validation(s) failed! ✗${NC}\n"
  exit 1
fi

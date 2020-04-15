# ncbi\_search
FILE: ncbi\_search.pl
AUTH: Paul Stothard <stothard@ualberta.ca>
DATE: August 20, 2008
VERS: 1.0

This script uses NCBI's Entrez Programming Utilities to perform searches of
NCBI databases. This script can return either the complete database records, or
the IDs of the records.

For additional information on NCBI's Entrez Programming Utilities see:
<https://www.ncbi.nlm.nih.gov/books/NBK25499/#chapter4.ESearch>

```
USAGE: perl ncbi_search.pl [-arguments]
  -q [STRING]     : raw query text (Required).
  -o [FILE]       : output file to create (Required).
  -d [STRING]     : name of the NCBI database to search, such as 'nucleotide',
                  'protein', or 'gene' (Required).
  -r [STRING]     : the type of information requested. For sequences 'fasta' is
                  often used. The accepted formats vary depending on the
                  database being queried (Required).
  -m [INTEGER]    : the maximum number of records to return (Optional; default
                  is to return all matches satisfying the query).
  -v              : provide progress messages (Optional).
```

**Example usage:**

The following obtains up to 10 PubMed ids for articles found PubMed. The search
phrase is "dysphagia" and the search is restricted to Homo sapiens.

    perl ncbi_search.pl -q 'dysphagia AND homo sapiens[ORGN]' \
    -o results.txt -d pubmed -r uilist -m 100

The following obtains up to 50 protein sequences in fasta format from GenBank.
The search phrase is "telomere" and the search not restricted to any organsim.

    perl ncbi_search.pl -q telomere -o results.txt \
    -d protein -r fasta -m 50

The following can be used to download a bacterial genome sequence:

    perl ncbi_search.pl -q 'Shewanella oneidensis[ORGN] AND nucleotide \
    genome[Filter] AND refseq[Filter] NOT wgs[Filter]' -o results.fasta \
    -d nucleotide -r fasta -v

The following can be used to download gene names:

    perl ncbi_search.pl -q 'bos taurus[ORGANISM] AND 1[CHROMOSOME] AND \
    10000:1000000[BASE POSITION] AND bos taurus umd 3 1 1[ASSEMBLY NAME]' \
    -d gene -o test.txt -r text

**Exit status:**

If the script encounters an error it exits with a status of 1. If no error is
encountered the script exits with a status of 0 upon completing.

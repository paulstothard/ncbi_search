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
USAGE:
   perl ncbi_search.pl [-arguments]

  -q [STRING]     : Entrez query text (Required).
  -o [FILE]       : output file to create (Required). If the -s option is used, 
                    this is the output directory to create.
  -d [STRING]     : name of the NCBI database to search, such as 'nucleotide',
                    'protein', or 'gene' (Required).
  -r [STRING]     : the type of information to download. For sequences, 'fasta'
                    is typically specified. The accepted formats depend on the
                    database being queried (Optional).
  -m [INTEGER]    : the maximum number of records to return (Optional; default
                    is to return all matches satisfying the query).
  -s              : return each record as a separate file, using the accession
                    of the record as the filename. This option is only
                    supported for -r values of 'gb' and 'gbwithparts'
                    (Optional).
  -v              : provide progress messages (Optional).
  -h              : show this message (Optional).
```

**Example usage:**

```
perl ncbi_search.pl -q 'dysphagia AND homo sapiens[ORGN]' \
-o results.txt -d pubmed -r uilist -m 100
```

``` 
perl ncbi_search.pl -q telomere -o results.txt \
-d protein -r fasta -m 50
```

```
perl ncbi_search.pl -q 'Shewanella oneidensis[ORGN] AND nucleotide \
genome[Filter] AND refseq[Filter] NOT wgs[Filter]' -o results.fasta \
-d nucleotide -r fasta -v
```

```
perl ncbi_search.pl -q 'bos taurus[ORGANISM] AND 1[CHROMOSOME] AND \
10000:1000000[BASE POSITION] AND bos taurus umd 3 1 1[ASSEMBLY NAME]' \
-d gene -o test.txt -r gene_table.txt
```

**Supported -d values:**

```
pubmed
protein
nuccore
ipg
nucleotide
structure
sparcle
genome
annotinfo
assembly
bioproject
biosample
blastdbinfo
books
cdd
clinvar
gap
gapplus
grasp
dbvar
gene
gds
geoprofiles
homologene
medgen
mesh
ncbisearch
nlmcatalog
omim
orgtrack
pmc
popset
probe
proteinclusters
pcassay
biosystems
pccompound
pcsubstance
seqannot
snp
sra
taxonomy
```

**Supported -r values:**

<table>

<tbody>

<tr>

<td scope="row" rowspan="1" colspan="1" style="text-align:center;vertical-align:top;">**Record Type**</td>

<td rowspan="1" colspan="1" style="text-align:center;vertical-align:top;">**&rettype**</td>

<td rowspan="1" colspan="1" style="text-align:center;vertical-align:top;">**&retmode**</td>

</tr>

<tr>

<td colspan="3" scope="col" rowspan="1" style="background-color:rgb(218,238,243);text-align:center;vertical-align:top;">**All Databases**</td>

</tr>

<tr>

<td scope="row" rowspan="1" colspan="1" style="text-align:left;vertical-align:top;">Document summary</td>

<td rowspan="1" colspan="1" style="text-align:left;vertical-align:top;">docsum</td>

<td rowspan="1" colspan="1" style="text-align:left;vertical-align:top;">xml, _default_</td>

</tr>

<tr>

<td scope="row" rowspan="1" colspan="1" style="text-align:left;vertical-align:top;">List of UIDs in XML</td>

<td rowspan="1" colspan="1" style="text-align:left;vertical-align:top;">uilist</td>

<td rowspan="1" colspan="1" style="text-align:left;vertical-align:top;">xml</td>

</tr>

<tr>

<td scope="row" rowspan="1" colspan="1" style="text-align:left;vertical-align:top;">List of UIDs in plain text</td>

<td rowspan="1" colspan="1" style="text-align:left;vertical-align:top;">uilist</td>

<td rowspan="1" colspan="1" style="text-align:left;vertical-align:top;">text</td>

</tr>

<tr>

<td colspan="3" scope="col" rowspan="1" style="background-color:rgb(218,238,243);text-align:center;vertical-align:top;">**db = bioproject**</td>

</tr>

<tr>

<td scope="row" rowspan="1" colspan="1" style="text-align:left;vertical-align:top;">Full record XML</td>

<td rowspan="1" colspan="1" style="text-align:left;vertical-align:top;">xml, _default_</td>

<td rowspan="1" colspan="1" style="text-align:left;vertical-align:top;">xml, _default_</td>

</tr>

<tr>

<td colspan="3" scope="col" rowspan="1" style="background-color:rgb(218,238,243);text-align:center;vertical-align:top;">**db = biosample**</td>

</tr>

<tr>

<td scope="row" rowspan="1" colspan="1" style="text-align:left;vertical-align:top;">Full record XML</td>

<td rowspan="1" colspan="1" style="text-align:left;vertical-align:top;">full, _default_</td>

<td rowspan="1" colspan="1" style="text-align:left;vertical-align:top;">xml, _default_</td>

</tr>

<tr>

<td scope="row" rowspan="1" colspan="1" style="text-align:left;vertical-align:top;">Full record text</td>

<td rowspan="1" colspan="1" style="text-align:left;vertical-align:top;">full, _default_</td>

<td rowspan="1" colspan="1" style="text-align:left;vertical-align:top;">text</td>

</tr>

<tr>

<td colspan="3" scope="col" rowspan="1" style="background-color:rgb(218,238,243);text-align:center;vertical-align:top;">**db = biosystems**</td>

</tr>

<tr>

<td scope="row" rowspan="1" colspan="1" style="text-align:left;vertical-align:top;">Full record XML</td>

<td rowspan="1" colspan="1" style="text-align:left;vertical-align:top;">xml, _default_</td>

<td rowspan="1" colspan="1" style="text-align:left;vertical-align:top;">xml, _default_</td>

</tr>

<tr>

<td colspan="3" scope="col" rowspan="1" style="background-color:rgb(218,238,243);text-align:center;vertical-align:top;">**db = gds**</td>

</tr>

<tr>

<td scope="row" rowspan="1" colspan="1" style="text-align:left;vertical-align:top;">Summary</td>

<td rowspan="1" colspan="1" style="text-align:left;vertical-align:top;">summary, _default_</td>

<td rowspan="1" colspan="1" style="text-align:left;vertical-align:top;">text, _default_</td>

</tr>

<tr>

<td colspan="3" scope="col" rowspan="1" style="background-color:rgb(218,238,243);text-align:center;vertical-align:top;">**db = gene**</td>

</tr>

<tr>

<td scope="row" rowspan="1" colspan="1" style="text-align:left;vertical-align:bottom;">text ASN.1</td>

<td rowspan="1" colspan="1" style="text-align:left;vertical-align:bottom;">_null_</td>

<td rowspan="1" colspan="1" style="text-align:left;vertical-align:bottom;">asn.1, _default_</td>

</tr>

<tr>

<td scope="row" rowspan="1" colspan="1" style="text-align:left;vertical-align:bottom;">XML</td>

<td rowspan="1" colspan="1" style="text-align:left;vertical-align:bottom;">_null_</td>

<td rowspan="1" colspan="1" style="text-align:left;vertical-align:bottom;">xml</td>

</tr>

<tr>

<td scope="row" rowspan="1" colspan="1" style="text-align:left;vertical-align:bottom;">Gene table</td>

<td rowspan="1" colspan="1" style="text-align:left;vertical-align:bottom;">gene_table</td>

<td rowspan="1" colspan="1" style="text-align:left;vertical-align:bottom;">text</td>

</tr>

<tr>

<td colspan="3" scope="col" rowspan="1" style="background-color:rgb(218,238,243);text-align:center;vertical-align:top;">**db = homologene**</td>

</tr>

<tr>

<td scope="row" rowspan="1" colspan="1" style="text-align:left;vertical-align:bottom;">text ASN.1</td>

<td rowspan="1" colspan="1" style="text-align:left;vertical-align:bottom;">_null_</td>

<td rowspan="1" colspan="1" style="text-align:left;vertical-align:bottom;">asn.1, _default_</td>

</tr>

<tr>

<td scope="row" rowspan="1" colspan="1" style="text-align:left;vertical-align:bottom;">XML</td>

<td rowspan="1" colspan="1" style="text-align:left;vertical-align:bottom;">_null_</td>

<td rowspan="1" colspan="1" style="text-align:left;vertical-align:bottom;">xml</td>

</tr>

<tr>

<td scope="row" rowspan="1" colspan="1" style="text-align:left;vertical-align:bottom;">Alignment scores</td>

<td rowspan="1" colspan="1" style="text-align:left;vertical-align:bottom;">alignmentscores</td>

<td rowspan="1" colspan="1" style="text-align:left;vertical-align:bottom;">text</td>

</tr>

<tr>

<td scope="row" rowspan="1" colspan="1" style="text-align:left;vertical-align:bottom;">FASTA</td>

<td rowspan="1" colspan="1" style="text-align:left;vertical-align:bottom;">fasta</td>

<td rowspan="1" colspan="1" style="text-align:left;vertical-align:bottom;">text</td>

</tr>

<tr>

<td scope="row" rowspan="1" colspan="1" style="text-align:left;vertical-align:bottom;">HomoloGene</td>

<td rowspan="1" colspan="1" style="text-align:left;vertical-align:bottom;">homologene</td>

<td rowspan="1" colspan="1" style="text-align:left;vertical-align:bottom;">text</td>

</tr>

<tr>

<td colspan="3" scope="col" rowspan="1" style="background-color:rgb(218,238,243);text-align:center;vertical-align:top;">**db = mesh**</td>

</tr>

<tr>

<td scope="row" rowspan="1" colspan="1" style="text-align:left;vertical-align:top;">Full record</td>

<td rowspan="1" colspan="1" style="text-align:left;vertical-align:top;">full, _default_</td>

<td rowspan="1" colspan="1" style="text-align:left;vertical-align:top;">text, _default_</td>

</tr>

<tr>

<td colspan="3" scope="col" rowspan="1" style="background-color:rgb(218,238,243);text-align:center;vertical-align:top;">**db = nlmcatalog**</td>

</tr>

<tr>

<td scope="row" rowspan="1" colspan="1" style="text-align:left;vertical-align:top;">Full record</td>

<td rowspan="1" colspan="1" style="text-align:left;vertical-align:top;">_null_</td>

<td rowspan="1" colspan="1" style="text-align:left;vertical-align:top;">text, _default_</td>

</tr>

<tr>

<td scope="row" rowspan="1" colspan="1" style="text-align:left;vertical-align:top;">XML</td>

<td rowspan="1" colspan="1" style="text-align:left;vertical-align:top;">_null_</td>

<td rowspan="1" colspan="1" style="text-align:left;vertical-align:top;">xml</td>

</tr>

<tr>

<td colspan="3" scope="col" rowspan="1" style="background-color:rgb(218,238,243);text-align:center;vertical-align:top;">**db = nuccore, nucest, nucgss, protein or popset**</td>

</tr>

<tr>

<td scope="row" rowspan="1" colspan="1" style="text-align:left;vertical-align:bottom;">text ASN.1</td>

<td rowspan="1" colspan="1" style="text-align:left;vertical-align:bottom;">_null_</td>

<td rowspan="1" colspan="1" style="text-align:left;vertical-align:bottom;">text, _default_</td>

</tr>

<tr>

<td scope="row" rowspan="1" colspan="1" style="text-align:left;vertical-align:bottom;">binary ASN.1</td>

<td rowspan="1" colspan="1" style="text-align:left;vertical-align:bottom;">_null_</td>

<td rowspan="1" colspan="1" style="text-align:left;vertical-align:bottom;">asn.1</td>

</tr>

<tr>

<td scope="row" rowspan="1" colspan="1" style="text-align:left;vertical-align:bottom;">Full record in XML</td>

<td rowspan="1" colspan="1" style="text-align:left;vertical-align:bottom;">native</td>

<td rowspan="1" colspan="1" style="text-align:left;vertical-align:bottom;">xml</td>

</tr>

<tr>

<td scope="row" rowspan="1" colspan="1" style="text-align:left;vertical-align:bottom;">Accession number(s)</td>

<td rowspan="1" colspan="1" style="text-align:left;vertical-align:bottom;">acc</td>

<td rowspan="1" colspan="1" style="text-align:left;vertical-align:bottom;">text</td>

</tr>

<tr>

<td scope="row" rowspan="1" colspan="1" style="text-align:left;vertical-align:bottom;">FASTA</td>

<td rowspan="1" colspan="1" style="text-align:left;vertical-align:bottom;">fasta</td>

<td rowspan="1" colspan="1" style="text-align:left;vertical-align:bottom;">text</td>

</tr>

<tr>

<td scope="row" rowspan="1" colspan="1" style="text-align:left;vertical-align:bottom;">TinySeq XML</td>

<td rowspan="1" colspan="1" style="text-align:left;vertical-align:bottom;">fasta</td>

<td rowspan="1" colspan="1" style="text-align:left;vertical-align:bottom;">xml</td>

</tr>

<tr>

<td scope="row" rowspan="1" colspan="1" style="text-align:left;vertical-align:bottom;">SeqID string</td>

<td rowspan="1" colspan="1" style="text-align:left;vertical-align:bottom;">seqid</td>

<td rowspan="1" colspan="1" style="text-align:left;vertical-align:bottom;">text</td>

</tr>

<tr>

<td colspan="3" scope="col" rowspan="1" style="background-color:rgb(218,238,243);text-align:center;vertical-align:top;">**Additional options for db = nuccore, nucest, nucgss or popset**</td>

</tr>

<tr>

<td scope="row" rowspan="1" colspan="1" style="text-align:left;vertical-align:bottom;">GenBank flat file</td>

<td rowspan="1" colspan="1" style="text-align:left;vertical-align:bottom;">gb</td>

<td rowspan="1" colspan="1" style="text-align:left;vertical-align:bottom;">text</td>

</tr>

<tr>

<td scope="row" rowspan="1" colspan="1" style="text-align:left;vertical-align:bottom;">GBSeq XML</td>

<td rowspan="1" colspan="1" style="text-align:left;vertical-align:bottom;">gb</td>

<td rowspan="1" colspan="1" style="text-align:left;vertical-align:bottom;">xml</td>

</tr>

<tr>

<td scope="row" rowspan="1" colspan="1" style="text-align:left;vertical-align:bottom;">INSDSeq XML</td>

<td rowspan="1" colspan="1" style="text-align:left;vertical-align:bottom;">gbc</td>

<td rowspan="1" colspan="1" style="text-align:left;vertical-align:bottom;">xml</td>

</tr>

<tr>

<td colspan="3" scope="col" rowspan="1" style="background-color:rgb(218,238,243);text-align:center;vertical-align:top;">**Additional option for db = nuccore and protein**</td>

</tr>

<tr>

<td scope="row" rowspan="1" colspan="1" style="text-align:left;vertical-align:bottom;">Feature table</td>

<td rowspan="1" colspan="1" style="text-align:left;vertical-align:bottom;">ft</td>

<td rowspan="1" colspan="1" style="text-align:left;vertical-align:bottom;">text</td>

</tr>

<tr>

<td colspan="3" scope="col" rowspan="1" style="background-color:rgb(218,238,243);text-align:center;vertical-align:top;">**Additional option for db = nuccore**</td>

</tr>

<tr>

<td scope="row" rowspan="1" colspan="1" style="text-align:left;vertical-align:bottom;">GenBank flat file with full sequence (contigs)</td>

<td rowspan="1" colspan="1" style="text-align:left;vertical-align:bottom;">gbwithparts</td>

<td rowspan="1" colspan="1" style="text-align:left;vertical-align:bottom;">text</td>

</tr>

<tr>

<td scope="row" rowspan="1" colspan="1" style="text-align:left;vertical-align:bottom;">CDS nucleotide FASTA</td>

<td rowspan="1" colspan="1" style="text-align:left;vertical-align:bottom;">fasta_cds_na</td>

<td rowspan="1" colspan="1" style="text-align:left;vertical-align:bottom;">text</td>

</tr>

<tr>

<td scope="row" rowspan="1" colspan="1" style="text-align:left;vertical-align:bottom;">CDS protein FASTA</td>

<td rowspan="1" colspan="1" style="text-align:left;vertical-align:bottom;">fasta_cds_aa</td>

<td rowspan="1" colspan="1" style="text-align:left;vertical-align:bottom;">text</td>

</tr>

<tr>

<td colspan="3" scope="col" rowspan="1" style="background-color:rgb(218,238,243);text-align:center;vertical-align:top;">**Additional option for db = nucest**</td>

</tr>

<tr>

<td scope="row" rowspan="1" colspan="1" style="text-align:left;vertical-align:bottom;">EST report</td>

<td rowspan="1" colspan="1" style="text-align:left;vertical-align:bottom;">est</td>

<td rowspan="1" colspan="1" style="text-align:left;vertical-align:bottom;">text</td>

</tr>

<tr>

<td colspan="3" scope="col" rowspan="1" style="background-color:rgb(218,238,243);text-align:center;vertical-align:top;">**Additional option for db = nucgss**</td>

</tr>

<tr>

<td scope="row" rowspan="1" colspan="1" style="text-align:left;vertical-align:bottom;">GSS report</td>

<td rowspan="1" colspan="1" style="text-align:left;vertical-align:bottom;">gss</td>

<td rowspan="1" colspan="1" style="text-align:left;vertical-align:bottom;">text</td>

</tr>

<tr>

<td colspan="3" scope="col" rowspan="1" style="background-color:rgb(218,238,243);text-align:center;vertical-align:top;">**Additional options for db = protein**</td>

</tr>

<tr>

<td scope="row" rowspan="1" colspan="1" style="text-align:left;vertical-align:bottom;">GenPept flat file</td>

<td rowspan="1" colspan="1" style="text-align:left;vertical-align:bottom;">gp</td>

<td rowspan="1" colspan="1" style="text-align:left;vertical-align:bottom;">text</td>

</tr>

<tr>

<td scope="row" rowspan="1" colspan="1" style="text-align:left;vertical-align:bottom;">GBSeq XML</td>

<td rowspan="1" colspan="1" style="text-align:left;vertical-align:bottom;">gp</td>

<td rowspan="1" colspan="1" style="text-align:left;vertical-align:bottom;">xml</td>

</tr>

<tr>

<td scope="row" rowspan="1" colspan="1" style="text-align:left;vertical-align:bottom;">INSDSeq XML</td>

<td rowspan="1" colspan="1" style="text-align:left;vertical-align:bottom;">gpc</td>

<td rowspan="1" colspan="1" style="text-align:left;vertical-align:bottom;">xml</td>

</tr>

<tr>

<td scope="row" rowspan="1" colspan="1" style="text-align:left;vertical-align:bottom;">Identical Protein XML</td>

<td rowspan="1" colspan="1" style="text-align:left;vertical-align:bottom;">ipg</td>

<td rowspan="1" colspan="1" style="text-align:left;vertical-align:bottom;">xml</td>

</tr>

<tr>

<td colspan="3" scope="col" rowspan="1" style="background-color:rgb(218,238,243);text-align:center;vertical-align:top;">**db = pmc**</td>

</tr>

<tr>

<td scope="row" rowspan="1" colspan="1" style="text-align:left;vertical-align:top;">XML</td>

<td rowspan="1" colspan="1" style="text-align:left;vertical-align:top;">_null_</td>

<td rowspan="1" colspan="1" style="text-align:left;vertical-align:top;">xml, _default_</td>

</tr>

<tr>

<td scope="row" rowspan="1" colspan="1" style="text-align:left;vertical-align:top;">MEDLINE</td>

<td rowspan="1" colspan="1" style="text-align:left;vertical-align:top;">medline</td>

<td rowspan="1" colspan="1" style="text-align:left;vertical-align:top;">text</td>

</tr>

<tr>

<td colspan="3" scope="col" rowspan="1" style="background-color:rgb(218,238,243);text-align:center;vertical-align:top;">**db = pubmed**</td>

</tr>

<tr>

<td scope="row" rowspan="1" colspan="1" style="text-align:left;vertical-align:top;">text ASN.1</td>

<td rowspan="1" colspan="1" style="text-align:left;vertical-align:top;">_null_</td>

<td rowspan="1" colspan="1" style="text-align:left;vertical-align:top;">asn.1_, default_</td>

</tr>

<tr>

<td scope="row" rowspan="1" colspan="1" style="text-align:left;vertical-align:top;">XML</td>

<td rowspan="1" colspan="1" style="text-align:left;vertical-align:top;">_null_</td>

<td rowspan="1" colspan="1" style="text-align:left;vertical-align:top;">xml</td>

</tr>

<tr>

<td scope="row" rowspan="1" colspan="1" style="text-align:left;vertical-align:top;">MEDLINE</td>

<td rowspan="1" colspan="1" style="text-align:left;vertical-align:top;">medline</td>

<td rowspan="1" colspan="1" style="text-align:left;vertical-align:top;">text</td>

</tr>

<tr>

<td scope="row" rowspan="1" colspan="1" style="text-align:left;vertical-align:top;">PMID list</td>

<td rowspan="1" colspan="1" style="text-align:left;vertical-align:top;">uilist</td>

<td rowspan="1" colspan="1" style="text-align:left;vertical-align:top;">text</td>

</tr>

<tr>

<td scope="row" rowspan="1" colspan="1" style="text-align:left;vertical-align:top;">Abstract</td>

<td rowspan="1" colspan="1" style="text-align:left;vertical-align:top;">abstract</td>

<td rowspan="1" colspan="1" style="text-align:left;vertical-align:top;">text</td>

</tr>

<tr>

<td colspan="3" scope="col" rowspan="1" style="background-color:rgb(218,238,243);text-align:center;vertical-align:top;">**db = sequences**</td>

</tr>

<tr>

<td scope="row" rowspan="1" colspan="1" style="text-align:left;vertical-align:bottom;">text ASN.1</td>

<td rowspan="1" colspan="1" style="text-align:left;vertical-align:bottom;">_null_</td>

<td rowspan="1" colspan="1" style="text-align:left;vertical-align:bottom;">text, _default_</td>

</tr>

<tr>

<td scope="row" rowspan="1" colspan="1" style="text-align:left;vertical-align:bottom;">Accession number(s)</td>

<td rowspan="1" colspan="1" style="text-align:left;vertical-align:bottom;">acc</td>

<td rowspan="1" colspan="1" style="text-align:left;vertical-align:bottom;">text</td>

</tr>

<tr>

<td scope="row" rowspan="1" colspan="1" style="text-align:left;vertical-align:bottom;">FASTA</td>

<td rowspan="1" colspan="1" style="text-align:left;vertical-align:bottom;">fasta</td>

<td rowspan="1" colspan="1" style="text-align:left;vertical-align:bottom;">text</td>

</tr>

<tr>

<td scope="row" rowspan="1" colspan="1" style="text-align:left;vertical-align:bottom;">SeqID string</td>

<td rowspan="1" colspan="1" style="text-align:left;vertical-align:bottom;">seqid</td>

<td rowspan="1" colspan="1" style="text-align:left;vertical-align:bottom;">text</td>

</tr>

<tr>

<td colspan="3" scope="col" rowspan="1" style="background-color:rgb(218,238,243);text-align:center;vertical-align:top;">**db = snp**</td>

</tr>

<tr>

<td scope="row" rowspan="1" colspan="1" style="text-align:left;vertical-align:bottom;">text ASN.1</td>

<td rowspan="1" colspan="1" style="text-align:left;vertical-align:bottom;">_null_</td>

<td rowspan="1" colspan="1" style="text-align:left;vertical-align:bottom;">asn.1, _default_</td>

</tr>

<tr>

<td scope="row" rowspan="1" colspan="1" style="text-align:left;vertical-align:bottom;">XML</td>

<td rowspan="1" colspan="1" style="text-align:left;vertical-align:bottom;">_null_</td>

<td rowspan="1" colspan="1" style="text-align:left;vertical-align:bottom;">xml</td>

</tr>

<tr>

<td scope="row" rowspan="1" colspan="1" style="text-align:left;vertical-align:bottom;">Flat file</td>

<td rowspan="1" colspan="1" style="text-align:left;vertical-align:bottom;">flt</td>

<td rowspan="1" colspan="1" style="text-align:left;vertical-align:bottom;">text</td>

</tr>

<tr>

<td scope="row" rowspan="1" colspan="1" style="text-align:left;vertical-align:bottom;">FASTA</td>

<td rowspan="1" colspan="1" style="text-align:left;vertical-align:bottom;">fasta</td>

<td rowspan="1" colspan="1" style="text-align:left;vertical-align:bottom;">text</td>

</tr>

<tr>

<td scope="row" rowspan="1" colspan="1" style="text-align:left;vertical-align:bottom;">RS Cluster report</td>

<td rowspan="1" colspan="1" style="text-align:left;vertical-align:bottom;">rsr</td>

<td rowspan="1" colspan="1" style="text-align:left;vertical-align:bottom;">text</td>

</tr>

<tr>

<td scope="row" rowspan="1" colspan="1" style="text-align:left;vertical-align:bottom;">SS Exemplar list</td>

<td rowspan="1" colspan="1" style="text-align:left;vertical-align:bottom;">ssexemplar</td>

<td rowspan="1" colspan="1" style="text-align:left;vertical-align:bottom;">text</td>

</tr>

<tr>

<td scope="row" rowspan="1" colspan="1" style="text-align:left;vertical-align:bottom;">Chromosome report</td>

<td rowspan="1" colspan="1" style="text-align:left;vertical-align:bottom;">chr</td>

<td rowspan="1" colspan="1" style="text-align:left;vertical-align:bottom;">text</td>

</tr>

<tr>

<td scope="row" rowspan="1" colspan="1" style="text-align:left;vertical-align:bottom;">Summary</td>

<td rowspan="1" colspan="1" style="text-align:left;vertical-align:bottom;">docset</td>

<td rowspan="1" colspan="1" style="text-align:left;vertical-align:bottom;">text</td>

</tr>

<tr>

<td scope="row" rowspan="1" colspan="1" style="text-align:left;vertical-align:bottom;">UID list</td>

<td rowspan="1" colspan="1" style="text-align:left;vertical-align:bottom;">uilist</td>

<td rowspan="1" colspan="1" style="text-align:left;vertical-align:bottom;">text or xml</td>

</tr>

<tr>

<td colspan="3" scope="col" rowspan="1" style="background-color:rgb(218,238,243);text-align:center;vertical-align:top;">**db = sra**</td>

</tr>

<tr>

<td scope="row" rowspan="1" colspan="1" style="text-align:left;vertical-align:bottom;">XML</td>

<td rowspan="1" colspan="1" style="text-align:left;vertical-align:bottom;">full, _default_</td>

<td rowspan="1" colspan="1" style="text-align:left;vertical-align:bottom;">xml, _default_</td>

</tr>

<tr>

<td colspan="3" scope="col" rowspan="1" style="background-color:rgb(218,238,243);text-align:center;vertical-align:bottom;">**db = taxonomy**</td>

</tr>

<tr>

<td scope="row" rowspan="1" colspan="1" style="text-align:left;vertical-align:bottom;">XML</td>

<td rowspan="1" colspan="1" style="text-align:left;vertical-align:bottom;">_null_</td>

<td rowspan="1" colspan="1" style="text-align:left;vertical-align:bottom;">xml, _default_</td>

</tr>

<tr>

<td scope="row" rowspan="1" colspan="1" style="text-align:left;vertical-align:bottom;">TaxID list</td>

<td rowspan="1" colspan="1" style="text-align:left;vertical-align:bottom;">uilist</td>

<td rowspan="1" colspan="1" style="text-align:left;vertical-align:bottom;">text or xml</td>

</tr>

<tr>

<td colspan="3" scope="col" rowspan="1" style="background-color:rgb(218,238,243);text-align:center;vertical-align:bottom;">**db = clinvar**</td>

</tr>

<tr>

<td scope="row" rowspan="1" colspan="1" style="text-align:left;vertical-align:bottom;">ClinVar Set</td>

<td rowspan="1" colspan="1" style="text-align:left;vertical-align:bottom;">clinvarset</td>

<td rowspan="1" colspan="1" style="text-align:left;vertical-align:bottom;">xml, _default_</td>

</tr>

<tr>

<td scope="row" rowspan="1" colspan="1" style="text-align:left;vertical-align:bottom;">UID list</td>

<td rowspan="1" colspan="1" style="text-align:left;vertical-align:bottom;">uilist</td>

<td rowspan="1" colspan="1" style="text-align:left;vertical-align:bottom;">text or xml</td>

</tr>

<tr>

<td colspan="3" scope="col" rowspan="1" style="background-color:rgb(218,238,243);text-align:center;vertical-align:bottom;">**db = gtr**</td>

</tr>

<tr>

<td scope="row" rowspan="1" colspan="1" style="text-align:left;vertical-align:bottom;">GTR Test Report</td>

<td rowspan="1" colspan="1" style="text-align:left;vertical-align:bottom;">gtracc</td>

<td rowspan="1" colspan="1" style="text-align:left;vertical-align:bottom;">xml, _default_</td>

</tr>

</tbody>

</table>
# ncbi\_search
FILE: ncbi\_search.pl  
AUTH: Paul Stothard <stothard@ualberta.ca>  
DATE: April 18, 2020  
VERS: 1.2

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
  -d [STRING]     : name of the NCBI database to search, such as 'nuccore',
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

### Example usage:

Download a sequence in GenBank format (with the full sequence included), using
an accession number:

```
perl ncbi_search.pl -q 'NC_045512[Accession]' \
        -o NC_045512.gbk \
        -d nuccore \
        -r gbwithparts \
        -v
```

Download the protein sequences encoded by a genome, using the genome's
accession number:

```
perl ncbi_search.pl -q 'NC_012920.1[Accession]' \
        -o AL513382.1.faa \
        -d nuccore \
        -r fasta_cds_aa \
        -v
```

Download multiple genomes using an accession number range, and save each genome
to a file named after its accession number:

```
perl ncbi_search.pl -q 'NC_009925:NC_009934[Accession]' \
        -o outdir1 \
        -d nuccore \
        -r gbwithparts \
        -s \
        -v
```

Download 10 coronavirus genomes from the RefSeq collection, and save each
genome to a separate file:

```
perl ncbi_search.pl -q 'coronavirus[Organism] AND nucleotide genome[Filter] AND refseq[Filter]' \
        -o outdir2 \
        -d nuccore \
        -r gbwithparts \
        -m 10 \
        -s \
        -v
```

Download 10 abstracts from PubMed using an author name:

```
perl ncbi_search.pl -q 'Stothard P[Author]' \
        -o abstracts.txt \
        -d pubmed \
        -r abstract \
        -m 10 \
        -v
```

Download information on the genes located in a genome region of interest:

```
perl ncbi_search.pl -q 'homo sapiens[Organism] AND 17[Chromosome] AND 7614064:7833711[Base position] AND GRCh38.p13[Assembly name]' \
        -o gene_list.txt \
        -d gene \
        -r gene_table \
        -v
```

Download information about a gene of interest:

```
perl ncbi_search.pl -q 'homo sapiens[Organism] AND PRNP[Gene name]' \
        -o gene_info.txt \
        -d gene \
        -v
```

Download information about health-affecting variants for a genome region of
interest:

```
perl ncbi_search.pl -q '17[Chromosome] AND 7614064:7620000[Base Position]' \
        -o clinvar_info.xml \
        -d clinvar \
        -r clinvarset \
        -v
```

___
### Supported -d option values:

* pubmed  
* protein  
* nuccore  
* ipg  
* nucleotide  
* structure  
* sparcle  
* genome  
* annotinfo  
* assembly  
* bioproject  
* biosample  
* blastdbinfo  
* books  
* cdd  
* clinvar  
* gap  
* gapplus  
* grasp  
* dbvar  
* gene  
* gds  
* geoprofiles  
* homologene  
* medgen  
* mesh  
* ncbisearch  
* nlmcatalog  
* omim  
* orgtrack  
* pmc  
* popset  
* probe  
* proteinclusters  
* pcassay  
* biosystems  
* pccompound  
* pcsubstance  
* seqannot  
* snp  
* sra  
* taxonomy  

___
### Supported -r option values:

The supported -r option values are grouped by database type (i.e. -d option value) below. The name of each format is followed by the corresponding -r option value in parentheses. A value of _null_ indicates that the -r option should be omitted in order to obtain that output format.  

#####  All Databases  
  * Document summary (docsum)  
  * List of UIDs in plain text (uilist)  

#####  d = bioproject  
  * Full record XML (xml)  

#####  d = biosample  
  * Full record text (full)  

#####  d = biosystems  
  * Full record XML (xml)  

#####  d = gds  
  * Summary (summary)  

#####  d = gene  
  * text ASN.1 (_null_)  
  * Gene table (gene_table)  

#####  d = homologene  
  * text ASN.1 (_null_)  
  * Alignment scores (alignmentscores)  
  * FASTA (fasta)  
  * HomoloGene (homologene)  

#####  d = mesh  
  * Full record (full)  

#####  d = nlmcatalog  
  * Full record (_null_)  

#####  d = nuccore, nucest, nucgss, protein or popset  
  * text ASN.1 (_null_)  
  * Full record in XML (native)  
  * Accession number(s) (acc)  
  * FASTA (fasta)  
  * SeqID string (seqid)  

#####  Additional options for d = nuccore, nucest, nucgss or popset  
  * GenBank flat file (gb)  
  * INSDSeq XML (gbc)  

#####  Additional option for d = nuccore and protein  
  * Feature table (ft)  

#####  Additional options for d = nuccore  
  * GenBank flat file with full sequence (gbwithparts)  
  * CDS nucleotide FASTA (fasta_cds_na)  
  * CDS protein FASTA (fasta_cds_aa)  

#####  Additional option for d = nucest  
  * EST report (est)  

#####  Additional option for d = nucgss  
  * GSS report (gss)  

#####  Additional options for d = protein  
  * GenPept flat file (gp)  
  * INSDSeq XML (gpc)  
  * Identical Protein XML (ipg)  

#####  d = pmc  
  * XML (_null_)  
  * MEDLINE (medline)  

#####  d = pubmed  
  * text ASN.1 (_null_)  
  * MEDLINE (medline)  
  * PMID list (uilist)  
  * Abstract (abstract)  

#####  d = sequences  
  * text ASN.1 (_null_)  
  * Accession number(s) (acc)  
  * FASTA (fasta)  
  * SeqID string (seqid)  

#####  d = snp  
  * text ASN.1 (_null_)  
  * Flat file (flt)  
  * FASTA (fasta)  
  * RS Cluster report (rsr)  
  * SS Exemplar list (ssexemplar)  
  * Chromosome report (chr)  
  * Summary (docset)  
  * UID list (uilist)  

#####  d = sra  
  * XML (full)  

#####  d = taxonomy  
  * XML (_null_)  
  * TaxID list (uilist)  

#####  d = clinvar  
  * ClinVar Set (clinvarset)  
  * UID list (uilist)  

#####  d = gtr  
  * GTR Test Report (gtracc)  

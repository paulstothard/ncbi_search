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

### Example usage:

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

##### Record Type (-r value) 

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

#####  Additional option for d = nuccore  
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

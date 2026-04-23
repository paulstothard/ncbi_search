# ncbi_search

A command-line tool for searching and downloading data from NCBI databases using the [Entrez Programming Utilities (E-utilities)](https://www.ncbi.nlm.nih.gov/books/NBK25499/). This script enables programmatic access to sequences, publications, gene information, and other biological data from NCBI's extensive database collection.

**Repository:** https://github.com/paulstothard/ncbi_search

## Features

- Search any NCBI database using Entrez query syntax
- Download complete records or specific data formats (FASTA, GenBank, XML, etc.)
- Retrieve individual records or batch downloads
- Save records as single files or separate files per record
- Built-in retry logic for reliable data retrieval

## Installation

### Requirements

- Perl 5.8 or later
- `LWP::Protocol::https` Perl module

### Setup

Install the required Perl module using conda:

```bash
conda install -c bioconda perl-lwp-protocol-https
```

Or using CPAN:

```bash
cpan LWP::Protocol::https
```

### Download

Clone the repository:

```bash
git clone https://github.com/paulstothard/ncbi_search.git
cd ncbi_search
```

Or download the script directly:

```bash
curl -O https://raw.githubusercontent.com/paulstothard/ncbi_search/main/ncbi_search.pl
chmod +x ncbi_search.pl
```

## Usage

### Quick Start

Display help information:

```bash
perl ncbi_search.pl --help
```

Basic syntax:

```bash
perl ncbi_search.pl -q '<query>' -o <output> -d <database> [options]
```

### Command-Line Options

**Required Arguments:**

- `-q` — Entrez query text (use NCBI search field syntax)
- `-o` — Output file path (or directory when using `-s`)
- `-d` — NCBI database name (e.g., `nuccore`, `protein`, `pubmed`)

**Optional Arguments:**

- `-r` — Return format (e.g., `fasta`, `gb`, `xml`). Default returns complete records
- `-m` — Maximum number of records to download (default: all matching records)
- `--sort` — Sort order for results (e.g., `accession`, `pub_date`). Default: `none`
- `-s` — Save each record as a separate file (only for `-r gb` or `gbwithparts`)
- `-v` — Display verbose progress messages

**Examples:**

```bash
# Download SARS-CoV-2 genome in GenBank format
perl ncbi_search.pl -q 'NC_045512[Accession]' -o NC_045512.gbk -d nuccore -r gbwithparts

# Download 10 coronavirus sequences in FASTA format, sorted by accession
perl ncbi_search.pl -q 'txid2[Organism:exp]' -o out.fasta -d nuccore -r fasta -m 10 --sort accession
```

## Examples

### Sequences

**Download a genome in GenBank format:**

```bash
perl ncbi_search.pl -q 'NC_045512[Accession]' \
  -o NC_045512.gbk \
  -d nuccore \
  -r gbwithparts \
  -v
```

**Extract protein sequences from a genome:**

```bash
perl ncbi_search.pl -q 'NC_012920.1[Accession]' \
  -o AL513382.1.faa \
  -d nuccore \
  -r fasta_cds_aa \
  -v
```

**Batch download genomes using accession ranges:**

```bash
perl ncbi_search.pl -q 'NC_009925:NC_009934[Accession]' \
  -o outdir1 \
  -d nuccore \
  -r gbwithparts \
  -s \
  -v
```

**Download multiple coronavirus genomes as separate files:**

```bash
perl ncbi_search.pl -q 'coronavirus[Organism] AND nucleotide genome[Filter] AND refseq[Filter]' \
  -o outdir2 \
  -d nuccore \
  -r gbwithparts \
  -m 5 \
  -s \
  -v
```

### Publications

**Download abstracts from PubMed:**

```bash
perl ncbi_search.pl -q 'Stothard P[Author]' \
  -o abstracts.txt \
  -d pubmed \
  -r abstract \
  -m 5 \
  -v
```

**Download abstracts sorted by publication date:**

```bash
perl ncbi_search.pl -q 'Stothard P[Author]' \
  -o abstracts_sorted.txt \
  -d pubmed \
  -r abstract \
  -m 5 \
  --sort pub_date \
  -v
```

### Gene Information

**Find genes in a specific genomic region:**

```bash
perl ncbi_search.pl -q 'homo sapiens[Organism] AND 17[Chromosome] AND 7614064:7833711[Base position] AND GRCh38.p13[Assembly name]' \
  -o gene_list.txt \
  -d gene \
  -r gene_table \
  -v
```

**Retrieve information about a specific gene:**

```bash
perl ncbi_search.pl -q 'homo sapiens[Organism] AND PRNP[Gene name]' \
  -o gene_info.txt \
  -d gene \
  -v
```

### Clinical Variants

**Download ClinVar data for a genomic region:**

```bash
perl ncbi_search.pl -q '17[Chromosome] AND 7614064:7620000[Base Position]' \
  -o clinvar_info.xml \
  -d clinvar \
  -r clinvarset \
  -v
```

### Batch Processing

**Download sequences from a list of accessions:**

```bash
# Create a file with accession numbers
echo $'NP_776246.1\nNP_001073369.1\nNP_995328.2\n' > accessions.txt

# Download each sequence using xargs
< accessions.txt xargs -t -I{} \
  perl ncbi_search.pl -q '{}[Accession]' \
    -o {}.fasta \
    -d protein \
    -r fasta \
    -v
```

**Split multi-sequence FASTA into individual files:**

```bash
# Download multi-sequence FASTA file
perl ncbi_search.pl -q 'coronavirus[Organism] AND nucleotide genome[Filter] AND refseq[Filter]' \
  -o sequences.fasta \
  -d nuccore \
  -r fasta \
  -m 5 \
  -v

# Split into separate files per sequence
outputdir=sequences/
mkdir -p "$outputdir"
awk '/^>/ {OUT=substr($0,2); split(OUT, a, " "); sub(/[^A-Za-z_0-9\.\-]/, "", a[1]); OUT = "'"$outputdir"'" a[1] ".fa"}; OUT {print >>OUT; close(OUT)}' \
  sequences.fasta
```

## Query Syntax

NCBI uses Entrez search fields to construct queries. Common search fields include:

- `[Accession]` — Search by accession number
- `[Organism]` — Search by organism name or taxonomy ID
- `[Gene name]` — Search by gene symbol
- `[Author]` — Search publications by author
- `[Title]` — Search publications by title
- `[All fields]` — Search all text fields
- `[Filter]` — Apply database-specific filters (e.g., `refseq[Filter]`)

Queries support Boolean operators (`AND`, `OR`, `NOT`) and ranges (e.g., `NC_009925:NC_009934[Accession]`).

**Resources:**

- [Entrez Help](https://www.ncbi.nlm.nih.gov/books/NBK3837/)
- [PubMed Search Field Descriptions](https://www.ncbi.nlm.nih.gov/books/NBK3827/#pubmedhelp.Search_Field_Descrip)
- [Nucleotide Advanced Search](https://www.ncbi.nlm.nih.gov/nuccore/advanced)
- [E-utilities Quick Start](https://www.ncbi.nlm.nih.gov/books/NBK25500/)

---

## Reference

### Supported Databases (`-d` option)

The following NCBI databases are supported:

| Database | Description | Link |
| --- | --- | --- |
| `nuccore` / `nucleotide` | Nucleotide sequences | [Browse](https://www.ncbi.nlm.nih.gov/nuccore/) |
| `protein` | Protein sequences | [Browse](https://www.ncbi.nlm.nih.gov/protein/) |
| `gene` | Gene records | [Browse](https://www.ncbi.nlm.nih.gov/gene/) |
| `pubmed` | PubMed citations | [Browse](https://pubmed.ncbi.nlm.nih.gov/) |
| `pmc` | PubMed Central full-text articles | [Browse](https://www.ncbi.nlm.nih.gov/pmc/) |
| `assembly` | Genome assemblies | [Browse](https://www.ncbi.nlm.nih.gov/assembly/) |
| `bioproject` | Biological projects | [Browse](https://www.ncbi.nlm.nih.gov/bioproject/) |
| `biosample` | Biological samples | [Browse](https://www.ncbi.nlm.nih.gov/biosample/) |
| `clinvar` | Clinical variants | [Browse](https://www.ncbi.nlm.nih.gov/clinvar/) |
| `snp` | SNPs and variants | [Browse](https://www.ncbi.nlm.nih.gov/snp/) |
| `sra` | Sequence Read Archive | [Browse](https://www.ncbi.nlm.nih.gov/sra/) |
| `taxonomy` | Taxonomic information | [Browse](https://www.ncbi.nlm.nih.gov/taxonomy/) |
| `structure` | 3D molecular structures | [Browse](https://www.ncbi.nlm.nih.gov/structure/) |
| `popset` | Population study datasets | [Browse](https://www.ncbi.nlm.nih.gov/popset/) |
| `genome` | Genome records | [Browse](https://www.ncbi.nlm.nih.gov/genome/) |

**Additional databases:** `annotinfo`, `biosystems`, `blastdbinfo`, `books`, `cdd`, `dbvar`, `gap`, `gapplus`, `gds`, `geoprofiles`, `grasp`, `homologene`, `ipg`, `medgen`, `mesh`, `ncbisearch`, `nlmcatalog`, `omim`, `orgtrack`, `pcassay`, `pccompound`, `pcsubstance`, `probe`, `proteinclusters`, `seqannot`, `sparcle`

For a complete list of databases and their descriptions, see [NCBI Database List](https://www.ncbi.nlm.nih.gov/search/).

---

### Supported Return Formats (`-r` option)

Return formats depend on the database being queried. Below are common formats grouped by database type. Format names are followed by the `-r` value in parentheses. _null_ indicates the `-r` option should be omitted to obtain the default format.

**For detailed format specifications, see [NCBI EFetch documentation](https://www.ncbi.nlm.nih.gov/books/NBK25499/table/chapter4.T._valid_values_of__retmode_and/).**

#### All Databases

- Document summary (`docsum`) — Structured summary information
- List of UIDs (`uilist`) — Plain text list of unique identifiers

#### Bioproject (`-d bioproject`)

- Full record XML (`xml`)

#### Biosample (`-d biosample`)

- Full record text (`full`)

#### Biosystems (`-d biosystems`)

- Full record XML (`xml`)

#### GDS - Gene Expression Omnibus (`-d gds`)

- Summary (`summary`)

#### Gene (`-d gene`)

- Text ASN.1 (_null_) — Default format
- Gene table (`gene_table`) — Tabular gene information

#### HomoloGene (`-d homologene`)

- Text ASN.1 (_null_) — Default format
- Alignment scores (`alignmentscores`)
- FASTA (`fasta`)
- HomoloGene (`homologene`)

#### MeSH (`-d mesh`)

- Full record (`full`)

#### NLM Catalog (`-d nlmcatalog`)

- Full record (_null_) — Default format

#### Nucleotide/Protein Sequences (`-d nuccore`, `nucest`, `nucgss`, `protein`, or `popset`)

- Text ASN.1 (_null_) — Default format
- Full record XML (`native`) — Native XML format
- Accession number(s) (`acc`)
- FASTA (`fasta`)
- SeqID string (`seqid`)

**Additional formats for `nuccore`, `nucest`, `nucgss`, or `popset`:**

- GenBank flat file (`gb`)
- INSDSeq XML (`gbc`)

**Additional formats for `nuccore` and `protein`:**

- Feature table (`ft`) — Sequence features in tabular format

**Additional formats for `nuccore` only:**

- GenBank flat file with full sequence (`gbwithparts`) — Complete sequence data
- CDS nucleotide FASTA (`fasta_cds_na`) — Coding sequences (nucleotide)
- CDS protein FASTA (`fasta_cds_aa`) — Translated proteins from CDS

**Additional formats for `nucest`:**

- EST report (`est`)

**Additional formats for `nucgss`:**

- GSS report (`gss`)

**Additional formats for `protein`:**

- GenPept flat file (`gp`)
- INSDSeq XML (`gpc`)
- Identical Protein XML (`ipg`)

#### PubMed Central (`-d pmc`)

- XML (_null_) — Default format
- MEDLINE (`medline`) — MEDLINE format

#### PubMed (`-d pubmed`)

- Text ASN.1 (_null_) — Default format
- MEDLINE (`medline`) — MEDLINE format
- PMID list (`uilist`) — List of PubMed IDs
- Abstract (`abstract`) — Article abstracts only

#### Sequences (`-d sequences`)

- Text ASN.1 (_null_) — Default format
- Accession number(s) (`acc`)
- FASTA (`fasta`)
- SeqID string (`seqid`)

#### SNP (`-d snp`)

- Text ASN.1 (_null_) — Default format
- Flat file (`flt`)
- FASTA (`fasta`)
- RS Cluster report (`rsr`)
- SS Exemplar list (`ssexemplar`)
- Chromosome report (`chr`)
- Summary (`docset`)
- UID list (`uilist`)

#### Sequence Read Archive (`-d sra`)

- XML (`full`)

#### Taxonomy (`-d taxonomy`)

- XML (_null_) — Default format
- TaxID list (`uilist`) — Taxonomy ID list

#### ClinVar (`-d clinvar`)

- ClinVar Set (`clinvarset`) — Complete variant information
- UID list (`uilist`)

#### Genetic Testing Registry (`-d gtr`)

- GTR Test Report (`gtracc`)

---

## License

See [LICENSE](LICENSE) file for details.

## Contributing

Contributions are welcome! Please submit issues or pull requests on [GitHub](https://github.com/paulstothard/ncbi_search).

## Citation

If you use this tool in your research, please cite:

- The NCBI E-utilities: [https://www.ncbi.nlm.nih.gov/books/NBK25497/](https://www.ncbi.nlm.nih.gov/books/NBK25497/)
- This repository: [https://github.com/paulstothard/ncbi_search](https://github.com/paulstothard/ncbi_search)

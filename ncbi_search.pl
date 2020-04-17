#!/usr/bin/perl
#FILE: ncbi_search.pl
#AUTH: Paul Stothard (stothard@ualberta.ca)
#DATE: August 20, 2008
#VERS: 1.2

use warnings;
use strict;
use Getopt::Long;
use URI::Escape;
use LWP::Protocol::https;
use LWP::UserAgent;
use HTTP::Request::Common;

my %param = (
    query         => undef,
    output_file   => undef,
    database      => undef,
    return_type   => '',
    max_records   => undef,
    format        => undef,
    verbose       => undef,
    split_records => undef,
    url           => 'https://www.ncbi.nlm.nih.gov/entrez/eutils',
    retries       => 0,
    max_retries   => 5,
    help          => undef
);

Getopt::Long::Configure('bundling');
GetOptions(
    'q|query=s'       => \$param{query},
    'o|output_file=s' => \$param{output_file},
    'd|database=s'    => \$param{database},
    'r|return_type=s' => \$param{return_type},
    'm|max_records=i' => \$param{max_records},
    's|split'         => \$param{split_records},
    'verbose|v'       => \$param{verbose},
    'h|help'          => \$param{help}
);

if ( defined( $param{help} ) ) {
    print_usage();
    exit(0);
}

if (   !( defined( $param{query} ) )
    or !( defined( $param{output_file} ) )
    or !( defined( $param{database} ) ) )
{
    print_usage();
    exit(1);
}

$param{return_type} = lc( $param{return_type} );

$param{query} = uri_escape( $param{query} );

# Set up for the -split option
if ( $param{split_records} ) {
    if (   ( $param{return_type} eq 'gb' )
        || ( $param{return_type} eq 'gbwithparts' ) )
    {
        if ( !( -d $param{output_file} ) ) {
            mkdir( $param{output_file}, 0775 )
              or
              die( "Could not create directory " . $param{output_file} . "." );
        }

    }
    else {
        $param{split_records} = 0;
        print
"-return_type is not 'gb' or 'gbwithparts', so the --split option will be ignored.\n";
    }
}

search(%param);

sub search {
    my %param = @_;

    my $esearch = "$param{url}/esearch.fcgi?db=$param{database}"
      . "&retmax=1&usehistory=y&term=$param{query}";

    my $ua = LWP::UserAgent->new(
        ssl_opts          => { verify_hostname => 0 },
        protocols_allowed => ['https'],
    );
    my $esearch_response = $ua->get($esearch);
    my $esearch_result   = $esearch_response->decoded_content;

    while (
        ( !defined($esearch_result) )
        || (
            !(
                $esearch_result =~
m/<Count>(\d+)<\/Count>.*<QueryKey>(\d+)<\/QueryKey>.*<WebEnv>(\S+)<\/WebEnv>/s
            )
        )
      )
    {
        if ( $esearch_result =~ m/<ERROR>(.*)<\/ERROR>/is ) {
            die("ESearch returned an error: $1");
        }
        message( $param{verbose},
            "ESearch results could not be parsed. Resubmitting query.\n" );
        sleep(10);
        if ( $param{retries} >= $param{max_retries} ) {
            die("Too many failures--giving up search.");
        }

        $esearch_response = $ua->get($esearch);
        $esearch_result   = $esearch_response->decoded_content;
        $param{retries}++;
    }

    $param{retries} = 0;

    $esearch_result =~
m/<Count>(\d+)<\/Count>.*<QueryKey>(\d+)<\/QueryKey>.*<WebEnv>(\S+)<\/WebEnv>/s;

    my $count     = $1;
    my $query_key = $2;
    my $web_env   = $3;

    if ( defined( $param{max_records} ) ) {
        if ( $count > $param{max_records} ) {
            message( $param{verbose},
"Retrieving $param{max_records} records out of $count available records.\n"
            );
            $count = $param{max_records};
        }
        else {
            message( $param{verbose},
                "Retrieving $count records out of $count available records.\n"
            );
        }
    }
    else {
        message( $param{verbose},
            "Retrieving $count records out of $count available records.\n" );
    }

    my $retmax = 500;

    if ( $param{split_records} ) {
        $retmax = 1;
    }

    if ( $retmax > $count ) {
        $retmax = $count;
    }

    my $OUTFILE;
    if ( !$param{split_records} ) {
        open( $OUTFILE, ">" . $param{output_file} )
          or die("Error: Cannot open $param{output_file} : $!");
    }

    for (
        my $retstart = 0 ;
        $retstart < $count ;
        $retstart = $retstart + $retmax
      )
    {
        if ( $retmax == 1 ) {
            message( $param{verbose},
                "Downloading record " . ( $retstart + 1 ) . "\n" );
        }
        else {
            message( $param{verbose},
                    "Downloading records "
                  . ( $retstart + 1 ) . " to "
                  . ( $retstart + $retmax )
                  . "\n" );
        }

        my $efetch =
"$param{url}/efetch.fcgi?rettype=$param{return_type}&retmode=text&retstart=$retstart&retmax=$retmax&db=$param{database}&query_key=$query_key&WebEnv=$web_env";
        my $efetch_response = $ua->get($efetch);
        my $efetch_result   = $efetch_response->decoded_content;

        while ( !defined($efetch_result) ) {
            message( $param{verbose},
                "EFetch results could not be parsed. Resubmitting query.\n" );
            sleep(10);
            if ( $param{retries} >= $param{max_retries} ) {
                die("Too many failures--giving up search.");
            }

            $efetch_response = $ua->get($efetch);
            $efetch_result   = $efetch_response->decoded_content;
            $param{retries}++;
        }

        $efetch_result =~ s/[^[:ascii:]]+//g;
        if ( $param{split_records} ) {
            my $record_num = $retstart + 1;
            write_split_record( $efetch_result, $record_num );
        }
        else {
            print( $OUTFILE $efetch_result );
        }

        unless (
            ( defined( $param{max_records} ) && ( $param{max_records} == 1 ) ) )
        {
            sleep(3);
        }
    }

    if ( !$param{split_records} ) {
        close($OUTFILE)
          or die("Error: Cannot close $param{output_file} file: $!");
    }
}

sub write_split_record {
    my $record     = shift;
    my $record_num = shift;
    if ( $record =~ /ACCESSION\s+(\S+)/ ) {
        my $accession = $1;
        open( my $RECORD_FILE, ">" . $param{output_file} . "/$accession.gbk" );
        print( $RECORD_FILE $record );
        close($RECORD_FILE);
    }
    else {
        print("Could not find accession line in record '$record_num'.\n");
    }
}

sub message {
    my $verbose = shift;
    my $message = shift;
    if ($verbose) {
        print $message;
    }
}

sub print_usage {
    print <<BLOCK;
DESCRIPTION:
This script uses NCBI's Entrez Programming Utilities to perform searches of
NCBI databases. This script can return either the complete database records, or
the IDs of the records.

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

EXAMPLE:
   perl ncbi_search.pl -q 'dysphagia AND homo sapiens[ORGN]' \\
     -o results.txt -d pubmed -r uilist -m 100

BLOCK
}

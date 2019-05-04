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
    query        => undef,
    outputFile   => undef,
    database     => undef,
    returnType   => undef,
    maxRecords   => undef,
    format       => undef,
    verbose      => undef,
    splitRecords => undef,
    url          => 'https://www.ncbi.nlm.nih.gov/entrez/eutils',
    retries      => 0,
    maxRetries   => 5,
    help         => undef
);

Getopt::Long::Configure('bundling');
GetOptions(
    'q|query=s'       => \$param{query},
    'o|output_file=s' => \$param{outputFile},
    'd|database=s'    => \$param{database},
    'r|return_type=s' => \$param{returnType},
    'm|max_records=i' => \$param{maxRecords},
    's|split'         => \$param{splitRecords},
    'verbose|v'       => \$param{verbose},
    'h|help'          => \$param{help}
);

if ( defined( $param{help} ) ) {
    print_usage();
    exit(0);
}

if (   !( defined( $param{query} ) )
    or !( defined( $param{outputFile} ) )
    or !( defined( $param{database} ) )
    or !( defined( $param{returnType} ) ) )
{
    print_usage();
    exit(1);
}

$param{returnType} = lc( $param{returnType} );

$param{query} = uri_escape( $param{query} );

# Set up for the split record option
if ( $param{splitRecords} ) {
    if ( ( $param{returnType} eq 'gb' ) || ( $param{returnType} eq 'gbwithparts') ) {
        if ( !( -d $param{outputFile} ) ) {
            mkdir( $param{outputFile}, 0775 )
                or die("Could not create directory " . $param{outputFile} . "." );
        }

    } else {
        $param{splitRecord} = 0;
        print "Return Type is not 'gb' or 'gbwithparts', so the Split option will be ignored.\n";
    }
}

_doSearch(%param);

sub _doSearch {
    my %param = @_;

    my $esearch = "$param{url}/esearch.fcgi?db=$param{database}"
        . "&retmax=1&usehistory=y&term=$param{query}";

    my $ua = LWP::UserAgent->new(
        ssl_opts => { verify_hostname => 0 },
        protocols_allowed => ['https'],
    );
    my $esearch_response = $ua->get($esearch);
    my $esearch_result = $esearch_response->decoded_content;

    while (
        ( !defined($esearch_result) )
        || (!(  $esearch_result
                =~ m/<Count>(\d+)<\/Count>.*<QueryKey>(\d+)<\/QueryKey>.*<WebEnv>(\S+)<\/WebEnv>/s
            )
        )
        )
    {
        if ($esearch_result =~ m/<ERROR>(.*)<\/ERROR>/is) {
            die("ESearch returned an error: $1");
        }
        message( $param{verbose},
            "ESearch results could not be parsed. Resubmitting query.\n" );
        sleep(10);
        if ( $param{retries} >= $param{maxRetries} ) {
            die("Too many failures--giving up search.");
        }

        $esearch_response = $ua->get($esearch);
        $esearch_result = $esearch_response->decoded_content;
        $param{retries}++;
    }

    $param{retries} = 0;

    $esearch_result
        =~ m/<Count>(\d+)<\/Count>.*<QueryKey>(\d+)<\/QueryKey>.*<WebEnv>(\S+)<\/WebEnv>/s;

    my $count     = $1;
    my $query_key = $2;
    my $web_env   = $3;

    if ( defined( $param{maxRecords} ) ) {
        if ( $count > $param{maxRecords} ) {
            message( $param{verbose},
                "Retrieving $param{maxRecords} records out of $count available records.\n"
            );
            $count = $param{maxRecords};
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
    # get record by record progress updates if splitting records
    if ( $param{splitRecords} ) {
        $retmax = 1;
    }

    if ( $retmax > $count ) {
        $retmax = $count;
    }

    my $OUTFILE;
    if ( ! $param{splitRecords} ) {
        open( $OUTFILE, ">" . $param{outputFile} )
            or die("Error: Cannot open $param{outputFile} : $!");
    }

    for (
        my $retstart = 0;
        $retstart < $count;
        $retstart = $retstart + $retmax
        )
    {
        if ( $retmax == 1) {
            message( $param{verbose},
                      "Downloading record "
                    . ( $retstart + 1 )
                    . "\n" );
        } else {
            message( $param{verbose},
                      "Downloading records "
                    . ( $retstart + 1 ) . " to "
                    . ( $retstart + $retmax )
                    . "\n" );
        }

        my $efetch
            = "$param{url}/efetch.fcgi?rettype=$param{returnType}&retmode=text&retstart=$retstart&retmax=$retmax&db=$param{database}&query_key=$query_key&WebEnv=$web_env";
        my $efetch_response = $ua->get($efetch);
        my $efetch_result = $efetch_response->decoded_content;

        while ( !defined($efetch_result) ) {
            message( $param{verbose},
                "EFetch results could not be parsed. Resubmitting query.\n" );
            sleep(10);
            if ( $param{retries} >= $param{maxRetries} ) {
                die("Too many failures--giving up search.");
            }

            $efetch_response = $ua->get($efetch);
            $efetch_result = $efetch_response->decoded_content;
            $param{retries}++;
        }

		$efetch_result =~ s/[^[:ascii:]]+//g;
        if ( $param{splitRecords} ) {
            my $record_num = $retstart + 1;
            write_split_record($efetch_result, $record_num);
        } else {
            print( $OUTFILE $efetch_result );
        }

        unless (
            ( defined( $param{maxRecords} ) && ( $param{maxRecords} == 1 ) ) )
        {
            sleep(3);
        }
    }

    if ( ! $param{splitRecords} ) {
        close($OUTFILE) or die("Error: Cannot close $param{outputFile} file: $!");
    }
}

sub write_split_record {
    my $record = shift;
    my $record_num = shift;
    if ( $record =~ /ACCESSION\s+(\S+)/ ) {
        my $accession = $1;
        open(my $RECORD_FILE, ">" . $param{outputFile} . "/$accession.gbk");
        print($RECORD_FILE $record);
        close($RECORD_FILE);
    } else {
        print("Could not find accession line in record $record_num\n");
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
USAGE:
   perl ncbi_search.pl -q STRING -o FILE -d STRING -r STRING [Options]

DESCRIPTION:
   Uses NCBI's eSearch to download collections of sequences.

REQUIRED ARGUMENTS:
   -q, --query [STRING]
      Raw query text.
   -o, --output [FILE]
      Output file to create. If the split option is given, this should be a
      directory, where the returned records will be written. If the directory
      does not exist it will be created. 
   -d, --database [STRING]
      Name of the NCBI database to search, such as 'nucleotide', 'protein',
      or 'gene'.
   -r, --return_type [STRING]
      The type of information requested. For sequences 'fasta' is often used.
      The accepted formats vary depending on the database being queried.
   -s, --split
      Return each record as a separate file where the file name will will be
      the accesssion id of the record. This option only works if the
      return_type is 'gb' or 'gbwithparts'.
   -m, --max_records [INTEGER]
      The maximum number of records to return (default is to return all matches
      satisfying the query).
   -v, --verbose
      Provide progress messages.
   -h, --help
      Show this message.

EXAMPLE:
   perl ncbi_search.pl -q 'dysphagia AND homo sapiens[ORGN]' \\
     -o results.txt -d pubmed -r uilist -m 100

BLOCK
}

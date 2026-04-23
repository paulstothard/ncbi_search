#!/usr/bin/env perl
# FILE: ncbi_search.pl
# AUTH: Paul Stothard (stothard@ualberta.ca)
# DATE: April 23, 2026
# VERS: 1.3

use strict;
use warnings;
use Getopt::Long;
use URI::Escape qw(uri_escape);
use LWP::Protocol::https;
use LWP::UserAgent;
use File::Path qw(make_path);
use File::Spec;

my %param = (
    query       => undef,
    output_file => undef,
    database    => undef,
    return_type => '',
    max_records => undef,
    sort        => 'none',
    verbose     => 0,
    separate    => 0,
    url         => 'https://www.ncbi.nlm.nih.gov/entrez/eutils',
    max_retries => 5,
    help        => 0,
);

Getopt::Long::Configure('no_bundling');

GetOptions(
    'q|query=s'       => \$param{query},
    'o|output_file=s' => \$param{output_file},
    'd|database=s'    => \$param{database},
    'r|return_type=s' => \$param{return_type},
    'm|max_records=i' => \$param{max_records},
    'sort=s'          => \$param{sort},
    's|separate'      => \$param{separate},
    'v|verbose'       => \$param{verbose},
    'h|help'          => \$param{help},
    )
    or do {
    print_usage();
    exit(1);
    };

if ( $param{help} ) {
    print_usage();
    exit(0);
}

validate_params( \%param );
prepare_output_mode( \%param );
search(%param);

sub validate_params {
    my ($param_ref) = @_;

    for my $required (qw(query output_file database)) {
        if ( !defined $param_ref->{$required} || $param_ref->{$required} eq '' ) {
            print_usage();
            exit(1);
        }
    }

    if ( defined $param_ref->{max_records} && $param_ref->{max_records} < 1 ) {
        die "Error: -m|max_records must be >= 1.\n";
    }

    $param_ref->{return_type} = lc( $param_ref->{return_type} // '' );

    if ( !defined $param_ref->{sort} || $param_ref->{sort} eq '' ) {
        $param_ref->{sort} = 'none';
    }

    $param_ref->{query} = uri_escape( $param_ref->{query} );
    $param_ref->{sort}  = uri_escape( $param_ref->{sort} );
}

sub prepare_output_mode {
    my ($param_ref) = @_;

    if ( $param_ref->{separate} ) {
        if ( $param_ref->{return_type} eq 'gb' || $param_ref->{return_type} eq 'gbwithparts' ) {
            if ( !-d $param_ref->{output_file} ) {
                make_path( $param_ref->{output_file} )
                    or die "Could not create directory '$param_ref->{output_file}'.\n";
            }
        }
        else {
            $param_ref->{separate} = 0;
            print "-r is not 'gb' or 'gbwithparts', so the -s option will be ignored.\n";
        }
    }
}

sub search {
    my %param = @_;

    my $ua = build_user_agent();

    my $esearch_url    = build_esearch_url(%param);
    my $esearch_result = get_with_retry(
        ua          => $ua,
        url         => $esearch_url,
        label       => 'ESearch',
        verbose     => $param{verbose},
        max_retries => $param{max_retries},
    );

    my ( $count, $query_key, $web_env ) = parse_esearch_result($esearch_result);

    if ( defined $param{max_records} ) {
        if ( $count > $param{max_records} ) {
            message( $param{verbose},
                "Retrieving $param{max_records} records out of $count available records.\n" );
            $count = $param{max_records};
        }
        else {
            message( $param{verbose},
                "Retrieving $count records out of $count available records.\n" );
        }
    }
    else {
        message( $param{verbose}, "Retrieving $count records out of $count available records.\n" );
    }

    my $batch_size = $param{separate} ? 1 : 500;
    $batch_size = $count if $batch_size > $count;

    my $outfile_fh;
    if ( !$param{separate} ) {
        open( $outfile_fh, '>', $param{output_file} )
            or die "Error: Cannot open '$param{output_file}' for writing: $!\n";
    }

    for ( my $retstart = 0 ; $retstart < $count ; $retstart += $batch_size ) {
        my $this_batch = $batch_size;
        if ( $retstart + $this_batch > $count ) {
            $this_batch = $count - $retstart;
        }

        if ( $this_batch == 1 ) {
            message( $param{verbose}, "Downloading record " . ( $retstart + 1 ) . "\n" );
        }
        else {
            message( $param{verbose},
                      "Downloading records "
                    . ( $retstart + 1 ) . " to "
                    . ( $retstart + $this_batch )
                    . "\n" );
        }

        my $efetch_url = build_efetch_url(
            %param,
            retstart  => $retstart,
            retmax    => $this_batch,
            query_key => $query_key,
            web_env   => $web_env,
        );

        my $efetch_result = get_with_retry(
            ua          => $ua,
            url         => $efetch_url,
            label       => 'EFetch',
            verbose     => $param{verbose},
            max_retries => $param{max_retries},
        );

        $efetch_result =~ s/[^[:ascii:]\n\r\t]+//g;

        if ( $param{separate} ) {
            write_separate_record(
                record     => $efetch_result,
                record_num => $retstart + 1,
                output_dir => $param{output_file},
            );
        }
        else {
            print {$outfile_fh} $efetch_result
                or die "Error: Failed writing to '$param{output_file}': $!\n";
        }

        unless ( defined( $param{max_records} ) && $param{max_records} == 1 ) {
            sleep(1);
        }
    }

    if ( !$param{separate} ) {
        close($outfile_fh)
            or die "Error: Cannot close '$param{output_file}': $!\n";
    }
}

sub build_user_agent {
    my $ua = LWP::UserAgent->new(

        # NOTE:
        # Hostname verification is intentionally disabled here because older or
        # misconfigured Perl/SSL environments can fail otherwise. This is less
        # secure than proper HTTPS verification, but still preferable to plain HTTP.
        ssl_opts          => { verify_hostname => 0 },
        protocols_allowed => ['https'],
        agent             => 'ncbi_search.pl/1.3',
        timeout           => 60,
    );

    return $ua;
}

sub build_esearch_url {
    my %param = @_;

    return
          "$param{url}/esearch.fcgi"
        . "?db=$param{database}"
        . "&retmax=1"
        . "&usehistory=y"
        . "&term=$param{query}"
        . "&sort=$param{sort}";
}

sub build_efetch_url {
    my %param = @_;

    my $url =
          "$param{url}/efetch.fcgi"
        . "?retmode=text"
        . "&retstart=$param{retstart}"
        . "&retmax=$param{retmax}"
        . "&db=$param{database}"
        . "&query_key=$param{query_key}"
        . "&WebEnv=$param{web_env}"
        . "&sort=$param{sort}";

    if ( $param{return_type} ne '' ) {
        $url .= "&rettype=$param{return_type}";
    }

    return $url;
}

sub get_with_retry {
    my %args = @_;

    my $ua          = $args{ua};
    my $url         = $args{url};
    my $label       = $args{label};
    my $verbose     = $args{verbose};
    my $max_retries = $args{max_retries};

    my $attempt = 0;

    while (1) {
        my $response = $ua->get($url);

        if ( $response->is_success ) {
            my $content = $response->decoded_content;
            if ( defined $content && $content ne '' ) {
                if ( $content =~ m/<ERROR>(.*?)<\/ERROR>/is ) {
                    die "$label returned an error: $1\n";
                }
                return $content;
            }
        }

        $attempt++;
        if ( $attempt > $max_retries ) {
            my $status = $response ? $response->status_line : 'no response';
            die "$label failed after $max_retries retries ($status).\n";
        }

        my $status = $response ? $response->status_line : 'no response';
        message( $verbose,
"$label request failed ($status). Retrying in 10 seconds (attempt $attempt/$max_retries)...\n"
        );
        sleep(10);
    }
}

sub parse_esearch_result {
    my ($result) = @_;

    if (
        $result =~ m{
            <Count>(\d+)</Count>.*?
            <QueryKey>(\d+)</QueryKey>.*?
            <WebEnv>(\S+)</WebEnv>
        }xs
        )
    {
        return ( $1, $2, $3 );
    }

    die "Could not parse ESearch response.\n";
}

sub write_separate_record {
    my %args = @_;

    my $record     = $args{record};
    my $record_num = $args{record_num};
    my $output_dir = $args{output_dir};

    if ( $record =~ /^ACCESSION\s+(\S+)/m ) {
        my $accession = $1;
        my $filename  = File::Spec->catfile( $output_dir, "$accession.gbk" );
        my $count     = 0;

        while ( -e $filename ) {
            $filename = File::Spec->catfile( $output_dir, "${accession}_$count.gbk" );
            $count++;
        }

        open( my $record_fh, '>', $filename )
            or die "Error: Cannot open '$filename' for writing: $!\n";
        print {$record_fh} $record
            or die "Error: Failed writing to '$filename': $!\n";
        close($record_fh)
            or die "Error: Cannot close '$filename': $!\n";
    }
    else {
        print "Could not find accession line in record '$record_num'.\n";
    }
}

sub message {
    my ( $verbose, $text ) = @_;
    print $text if $verbose;
}

sub print_usage {
    print <<'BLOCK';
ncbi_search.pl - search NCBI databases.

DISPLAY HELP AND EXIT:

usage:

  perl ncbi_search.pl --help

PERFORM NCBI SEARCH:

usage:

  perl ncbi_search.pl -q <string> -o <file> -d <string> [options]

required arguments:

-q - Entrez query text.

-o - Output file to create. If the -s option is used this is the output
directory to create.

-d - Name of the NCBI database to search, such as 'nuccore', 'protein', or
'gene'.

optional arguments:

-r - Type of information to download. For sequences, 'fasta' is typically
specified. The accepted formats depend on the database being queried. The
default is to specify no format.

-m - The maximum number of records to download. Default is to download all
records.

--sort - Sort order for ESearch/EFetch. Default is 'none'.

-s - Save each record as a separate file. This option is only supported for -r
values of 'gb' and 'gbwithparts'.

-v - Provide progress messages.

example usage:

  perl ncbi_search.pl -q 'NC_045512[Accession]' -o NC_045512.gbk -d nuccore \
  -r gbwithparts

  perl ncbi_search.pl -q 'txid2[Organism:exp]' -o out.fasta -d nuccore \
  -r fasta -m 10 --sort accession
BLOCK
}

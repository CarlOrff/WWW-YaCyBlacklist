use strict;
use warnings;

package WWW::YaCyBlacklist;
# ABSTRACT: a Perl module to parse and execute YaCy blacklists

our $AUTHORITY = 'cpan:IBRAUN';
$WWW::YaCyBlacklist::VERSION = '0.00';

use Moose;
use IO::All;
use URI::URL;
use Data::Dumper;

# Needed if RegExps do not compile
has 'use_regex' => (
    is  => 'ro',
    isa => 'Bool',
    default => 1,
);

# Needed if RegExps do not compile
has 'file_charset' => (
    is  => 'ro',
    isa => 'Str',
    default => 'cp1252', # YaCy files are encoded in ANSI
    init_arg => undef,
);

has 'lines' => (
    is  => 'rw',
    isa => 'Int',
    default => 0,
    init_arg => undef,
);
 
has 'origorder' => (
    is  => 'rw',
    isa => 'Int',
    default => 0,
    init_arg => undef,
);

# 0 ascending, 1 descending
has 'sortorder' => (
    is  => 'rw',
    isa => 'Bool',
    default => 0,
);


has 'patterns' => (
    is=>'rw',
    isa => 'HashRef',
    traits  => [ 'Hash' ],
    default => sub { {} },
);

sub _check_host_regex {
    
    my ($self, $pattern) = @_;
    
    return 0 if $pattern =~ /^[\w\-\.\*]+$/; # underscores are not allowed in domain names but sometimes happen in subdomains
    return 1;
}

sub read_from_array {
    
    my ($self, @lines) = @_;
    my %hash;
     
    foreach my $line ( @lines ) {
        if ( CORE::length $line > 0 ) {
            $hash{ $line }{ 'origorder' } = $self->origorder( $self->origorder + 1 );
            ( $hash{ $line }{ 'host' }, $hash{ $line }{ 'path' } ) = split /(?!\\)\/+?/, $line, 2;
            $hash{ $line }{ 'host_regex' } = $self->_check_host_regex( $hash{ $line }{ 'host' } );
        }
    }
    
    $self->patterns( \%hash );
}

sub read_from_files {
    
    my ($self, @files) = @_;
    my @lines;
    
    grep { push( @lines, io( $_ )->encoding( $self->file_charset )->slurp ) } @files;
    $self->lines(scalar @lines);
    $self->read_from_array( @lines );
}

sub length {
    
    my $self = shift;
    return scalar keys %{ $self->patterns };
}

sub checkURL {
    
    my $self = shift;
    my $url = new URI $_[0];
    my $pq = ( defined $url->query ) ? $url->path.'?'.$url->query : $url->path;
    $pq =~ s/^\///;
    my %hash = %{$self->patterns};
    #Dumper(%hash) >> io('hash.txt');
    #my $count = 0;
    foreach my $pattern ( keys %hash ) {
        #++$count  . "\t" .  $url->host . $url->path . "\t\t" . $pattern . "\n" >> io('hash.txt');
        my $path = '^' . $hash{$pattern}{path} . '$';
        next if $pq !~ /$path/;
        my $host = $hash{$pattern}{host};
        if ( !$hash{$pattern}{host_regex} ) {
            $host =~ s/\*/.*/g;
            if ( $hash{$pattern}{host} =~ /\.\*$/ ) {
                return 1 if $url->host =~ /^$host$/;
            }
            else {
                return 1 if $url->host =~ /^(.+\.)?$host$/;
            }
        }
        else {
            return 1 if $url->host  =~ /^$host$/;
        }
    }
    return 0;
}


1;
no Moose;
__PACKAGE__->meta->make_immutable;
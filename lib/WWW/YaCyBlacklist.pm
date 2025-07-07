use strict;
use warnings;

package WWW::YaCyBlacklist;
# ABSTRACT: a Perl module to parse and execute YaCy blacklists

our $AUTHORITY = 'cpan:IBRAUN';
$WWW::YaCyBlacklist::VERSION = '0.00';

use Moose;
use Moose::Util::TypeConstraints;
use IO::All;
use URI::URL;

# Needed if RegExps do not compile
has 'use_regex' => (
    is  => 'ro',
    isa => 'Bool',
    default => 1,
);

# Needed if RegExps do not compile
has 'filename' => (
    is  => 'rw',
    isa => 'Str',
    default => 'url.ycb.black',
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

has 'sorting' => (
    is  => 'rw',
    isa => enum([qw[ alphabetical length origorder reverse_host ]]),,
    default => 'origorder',
);

has 'patterns' => (
    is=>'rw',
    isa => 'HashRef',
    traits  => [ 'Hash' ],
    default => sub { {} },
    init_arg => undef,
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

sub check_url {
    
    my $self = shift;
    my $url = new URI $_[0];
    my $pq = ( defined $url->query ) ? $url->path.'?'.$url->query : $url->path;
    $pq =~ s/^\///;
    
    foreach my $pattern ( keys %{ $self->patterns } ) {
        my $path = '^' . ${ $self->patterns }{ $pattern }{path} . '$';
        next if $pq !~ /$path/;
        my $host = ${ $self->patterns }{ $pattern }{host};
        
        if ( !${ $self->patterns }{ $pattern }{host_regex} ) {
            $host =~ s/\*/.*/g;
            
            if ( ${ $self->patterns }{ $pattern }{host} =~ /\.\*$/ ) {
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

sub find_matches {
    
    my $self = shift;
    my @urls;
    grep { push( @urls, $_ ) if $self->check_url( $_ ) } @_;
    return @urls;
}


sub find_non_matches {
    
    my $self = shift;
    my @urls;
    grep { push( @urls, $_ ) if !$self->check_url( $_ ) } @_;
    return @urls;
}

sub delete_pattern {
    
    my $self = shift;
    my $pattern = shift;
    delete( ${ $self->patterns }{ $pattern } ) if exists( ${ $self->patterns }{ $pattern } ) ;
}

sub sort_list {
    
    my $self = shift;
    my @sorted_list;
  
    @sorted_list = sort keys %{ $self->patterns } if $self->sorting eq 'alphabetical';
    @sorted_list = sort { CORE::length $a <=> CORE::length $b } keys %{ $self->patterns } if $self->sorting eq 'length';
    @sorted_list = sort { ${ $self->patterns }{ $a }{ origorder } <=> ${ $self->patterns }{ $b }{ origorder } } keys %{ $self->patterns } if $self->sorting eq 'origorder';
    @sorted_list = sort { reverse( ${ $self->patterns }{ $a }{ host } ) cmp reverse( ${ $self->patterns }{ $b }{ host } ) } keys %{ $self->patterns }  if $self->sorting eq 'reverse_host';
    
   return @sorted_list if $self->sortorder;
   return reverse( @sorted_list );
}

sub store_list {
    
    my $self = shift;
    join( "\n", $self->sort_list ) > io(  $self->filename )->encoding( $self->file_charset )->all;
}

1;
no Moose;
__PACKAGE__->meta->make_immutable;
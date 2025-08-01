# NAME

WWW::YaCyBlacklist - a Perl module to parse and execute YaCy blacklists

# VERSION

version 0.7

# SYNOPSIS

    use WWW::YaCyBlacklist;

    my $ycb = WWW::YaCyBlacklist->new( { 'use_regex' => 1 } );
    $ycb->read_from_array(
        'test1.co/fullpath',
        'test2.co/.*',
    );
    $ycb->read_from_files(
        '/path/to/1.black',
        '/path/to/2.black',
    );

    print "Match!" if $ycb->check_url( 'http://test1.co/fullpath' );
    my @urls = (
        'https://www.perlmonks.org/',
        'https://metacpan.org/',
    );
    my @matches = $ycb->find_matches( @urls );
    my @nonmatches = $ycb->find_non_matches( @urls );

    $ycb->sortorder( 1 );
    $ycb->sorting( 'alphabetical' );
    $ycb->filename( '/path/to/new.black' );
    $ycb->store_list( );

# METHODS

## `new(%options)`

## `use_regex => 0|1` (default `1`)

Can only be set in the constructor and never be changed any later. If `false`, the pattern will not get checked if the
`host` part is a regular expression (but the patterns remain in the list).

## `filename => '/path/to/file.black'` (default `ycb.black`)

This is the file printed by `store_list`

## `sortorder =>  0|1` (default `0`)

0 ascending, 1 descending
Configures `sort_list`

## `sorting => 'alphabetical|length|origorder|random|reverse_host'` (default `'origorder`)

Configures `sort_list`

## `void read_from_array( @patterns )`

Reads a list of YaCy blacklist patterns.

## `void read_from_files( @files )`

Reads a list of YaCy blacklist files.

## `int length( )`

Returns the number of patterns in the current list.

## `bool check_url( $URL )`

1 if the URL was matched by any pattern, 0 otherwise.

## `@URLS_OUT find_matches( @URLS_IN )`

Returns all URLs which was matches by the current list.

## `@URLS_OUT find_non_matches( @URLS_IN )`

Returns all URLs which was not matches by the current list.

## `void delete_pattern( $pattern )`

Removes a pattern from the current list.

## `@patterns sort_list( )`

Returns a list of patterns configured by `sorting` and `sortorder`.

## `void store_list( )`

Prints the current list to a file. Executes `sort_list( )`.

# OPERATIONAL NOTES

`WWW::YaCyBlacklist` checks the path part including the leading separator `/`. This protects against regexp compiling errors with leading quantifiers. So do not something like `host.tld/^path` although YaCy allows this.

`check_url( )` alway returns true if the protocol of the URL is not `https?` or `ftps?`.

# BUGS

YaCy does not allow host patterns with two ore more stars at the time being. `WWW::YaCyBlacklist` does not check for this but simply executes. This is rather a YaCy bug.

If there is something you would like to tell me, there are different channels for you:

- [GitHub issue tracker](https://github.com/CarlOrff/WWW-YaCyBlacklist/issues)
- [CPAN issue tracker](https://rt.cpan.org/Public/Dist/Display.html?WWW-YaCyBlacklist)
- [Project page on my homepage](https://ingram-braun.net/erga/the-www-yacyblacklist-module/)
- [Contact form on my homepage](https://ingram-braun.net/erga/legal-notice-and-contact/)

# SOURCE

- [De:Blacklists](https://wiki.yacy.net/index.php/De:Blacklists) (German).
- [Dev:APIlist](https://wiki.yacy.net/index.php/Dev:APIlist)

# SEE ALSO

- [YaCy homepage](https://yacy.net/)
- [YaCy community](https://community.searchlab.eu/)

# AUTHOR

Ingram Braun <carlorff1@gmail.com>

# COPYRIGHT AND LICENSE

This software is copyright (c) 2025 by Ingram Braun.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

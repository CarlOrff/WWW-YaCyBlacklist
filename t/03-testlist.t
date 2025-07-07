#!perl
use 5.006;
use strict;
use warnings;
use Test::More tests => 46;

require_ok( 'WWW::YaCyBlacklist' );

my $ycb = WWW::YaCyBlacklist->new( 'use_regex' => 1 );
$ycb->read_from_array(
    'test1.co/fullpath',
    'test2.co/.*',
    '*.test3.co/.*',
    '*.sub.test4.co/.*',
    'sub.test5.*/.*',
    'test6.*/.*',
    '(regexp)test7\.\w+/[a-z]+\.\w{1,5}',
    'test8.co/[a-z]+\.htm',
    'test9.co/%C3%A4%C3%B6%C3%BC%C3%9F%C3%84%C3%96%C3%9C',
    'test10.co/fullpath.-_',
    'test11.co/fullpath-_',
    'test12.co/fullpath-',
    'test13.co/fullpath1234567890',
    'test14.co/fullpath?ref=test',
    'test15.co/fullpath\?ref=test',
    'sub.test16.co/.*',
    'test17.co/^fullpath$',
);
is( $ycb->checkURL( 'http://test1.co/fullpath' ), 1, 'match0' );
is( $ycb->checkURL( 'http://sub.test1.co/fullpath' ), 1, 'match1' );
is( $ycb->checkURL( 'http://test2.co/fullpath' ), 1, 'match2' );
is( $ycb->checkURL( 'http://sub.test2.co/fullpath' ), 1, 'match3' );
is( $ycb->checkURL( 'http://sub.sub.sub.test2.co/fullpath' ), 1, 'match4' );
is( $ycb->checkURL( 'http://sub.test3.co/fullpath' ), 1, 'match5' );
is( $ycb->checkURL( 'http://sub.sub.test3.co/fullpath' ), 1, 'match6' );
is( $ycb->checkURL( 'http://sub.sub.sub.test3.co/fullpath' ), 1, 'match7' );
is( $ycb->checkURL( 'http://sub.sub.test4.co/fullpath' ), 1, 'match8' );
is( $ycb->checkURL( 'http://sub.sub.sub.test4.co/fullpath' ), 1, 'match9' );
is( $ycb->checkURL( 'http://sub.test5.co/fullpath' ), 1, 'match10' );
is( $ycb->checkURL( 'http://test6.co/fullpath' ), 1, 'match11' );
is( $ycb->checkURL( 'http://regexptest7.co/fullpath.html' ), 1, 'match12' );
is( $ycb->checkURL( 'http://test8.co/fullpath.htm' ), 1, 'match13' );
is( $ycb->checkURL( 'http://sub.test8.co/fullpath.htm' ), 1, 'match14' );
is( $ycb->checkURL( 'http://test9.co/%C3%A4%C3%B6%C3%BC%C3%9F%C3%84%C3%96%C3%9C' ), 1, 'match15' );
is( $ycb->checkURL( 'http://sub.test9.co/%C3%A4%C3%B6%C3%BC%C3%9F%C3%84%C3%96%C3%9C' ), 1, 'match16' );
is( $ycb->checkURL( 'http://test10.co/fullpath.-_' ), 1, 'match17' );
is( $ycb->checkURL( 'http://sub.test10.co/fullpath.-_' ), 1, 'match18' );
is( $ycb->checkURL( 'http://test11.co/fullpath-_' ), 1, 'match19' );
is( $ycb->checkURL( 'http://sub.test11.co/fullpath-_' ), 1, 'match20' );
is( $ycb->checkURL( 'http://test12.co/fullpath-' ), 1, 'match21' );
is( $ycb->checkURL( 'http://sub.test12.co/fullpath-' ), 1, 'match22' );
is( $ycb->checkURL( 'http://test13.co/fullpath1234567890' ), 1, 'match23' );
is( $ycb->checkURL( 'http://sub.test13.co/fullpath1234567890' ), 1, 'match24' );
is( $ycb->checkURL( 'http://test1.co/fullpatha' ), 0, 'nonmatch0' );
is( $ycb->checkURL( 'http://test1.co/afullpath' ), 0, 'nonmatch1' );
is( $ycb->checkURL( 'http://sub.test1.co/fullpatha' ), 0, 'nonmatch2' );
is( $ycb->checkURL( 'http://sub.test1.co/afullpath' ), 0, 'nonmatch3' );
is( $ycb->checkURL( 'http://test14.co/fullpath' ), 0, 'nonmatch4' );
is( $ycb->checkURL( 'http://sub.test14.co/fullpath' ), 0, 'nonmatch5' );
is( $ycb->checkURL( 'http://test14.co/fullpath?ref=test' ), 0, 'nonmatch6' );
is( $ycb->checkURL( 'http://sub.test14.co/fullpath?ref=test' ), 0, 'nonmatch7' );
is( $ycb->checkURL( 'http://test1.co/fullpath?ref=test' ), 0, 'nonmatch8' );
is( $ycb->checkURL( 'http://sub.test1.co/?ref=test' ), 0, 'nonmatch9' );
is( $ycb->checkURL( 'http://test6.co/fullpath?ref=test' ), 1, 'match25' );
is( $ycb->checkURL( 'http://sub.test6.co/fullpath?ref=test' ), 0, 'nonmatch10' );
is( $ycb->checkURL( 'http://test15.co/fullpath?ref=test' ), 1, 'match26' );
is( $ycb->checkURL( 'http://sub.test15.co/fullpath?ref=test' ), 1, 'match27' );
is( $ycb->checkURL( 'http://sub.test16.co/fullpath' ), 1, 'match28' );
is( $ycb->checkURL( 'http://sub.sub.test16.co/fullpath' ), 1, 'match29' );
is( $ycb->checkURL( 'http://sub.sub.sub.test16.co/fullpath' ), 1, 'match30' );
is( $ycb->checkURL( 'http://test17.co/fullpath' ), 1, 'match31' );
is( $ycb->checkURL( 'http://sub.test17.co/fullpath' ), 1, 'match32' );
is( $ycb->checkURL( 'http://sub.sub.test17.co/fullpath' ), 1, 'match33' );
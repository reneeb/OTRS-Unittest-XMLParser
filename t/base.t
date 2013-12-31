#!/usr/bin/perl

use strict;
use warnings;

use OTRS::Unittest::XMLParser;
use File::Spec;
use File::Basename;
use Test::More;

my $xml_file = File::Spec->catfile( dirname(__FILE__), 'data', 'test.xml' );
my $xml      = do{ local (@ARGV, $/) = $xml_file; <> };

my $parser = OTRS::Unittest::XMLParser->new( xml => $xml );

my @tests     = qw(
    /opt/otrs/scripts/test/JSON.t
    /opt/otrs/scripts/test/Layout.t
);
my %durations;
@durations{@tests} = (0,3);

my %states;
@states{@tests} = ('ok', 'not ok');

for my $test ( @{ $parser->tests || [] } ) {
    my $check_name = shift @tests;

    is $test->name, $check_name, "Name of test";
    is $test->duration, $durations{$check_name}, "Duration of test";
    is $test->state, $states{$check_name}, "State of test";
}

done_testing();

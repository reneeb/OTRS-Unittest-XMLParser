package OTRS::Unittest::XMLParser::Test;

# ABSTRACT: represent a '<Unit>' node of unittest output

use strict;
use warnings;

use Moo;
use List::Util qw(all);

our $VERSION = 0.01;

has name     => (is => 'ro', required => 1);
has duration => (is => 'ro', required => 1);
has state    => (is => 'ro', required => 1);

sub BUILDARGS {
    my ($class, @args) = @_;

    unshift @args, 'node' if @args % 2;

    my $name     = $args[1]->findvalue( '@Name' );
    my $duration = $args[1]->findvalue( '@Duration' );

    my @testnodes  = $args[1]->findnodes( 'Test' );
    my @teststates = map{ $_->findvalue( '@Result' ) }@testnodes;
    my $state      = all{ $_ eq 'ok' }@teststates;

    push @args,
        name     => $name,
        duration => $duration,
        state    => ($state ? 'ok' : 'not ok' );

    return {@args};
}

1;


package OTRS::Unittest::XMLParser;

# ABSTRACT: Parser for OTRS' unittest output (XML)

use strict;
use warnings;

use Moo;
use XML::LibXML;

use OTRS::Unittest::XMLParser::Test;

our $VERSION = 0.01;

has xml   => (is => 'ro', required => 1);
has tree  => (is => 'ro', builder  => 1);
has tests => (is => 'rwp');

has [qw/database host os perl product test_not_ok test_ok time time_taken vendor/] => (is => 'rwp');

sub BUILD {
    my ($self) = @_;

    my $root = $self->tree;

    for my $node (qw/Database Host OS Perl Product TestNotOk TestOk Time TimeTaken Vendor/) {
        my $attr_name = $node;
        $attr_name =~ s{[a-z]\K([A-Z])}{"_" . lc($1)}eg;
        $attr_name = lc $attr_name;

        my $value = $root->findvalue( 'Summary/Item[name="' . $node . '"]' );
        my $code  = $self->can( '_set_' . $attr_name );

        $self->$code( $value );
    }

    my @tests;
    my @test_nodes = $root->findnodes( 'Unit' );
    for my $node ( @test_nodes ) {
        my $obj = OTRS::Unittest::XMLParser::Test->new( node => $node );
        push @tests, $obj;
    }

    $self->_set_tests( \@tests );
}

sub BUILDARGS {
    my ($class, @args) = @_;

    unshift @args, 'xml' if @args % 2;

    my $tree = XML::LibXML->new->parse_string( $args[1] )->getDocumentElement;
    push @args, tree => $tree;

    return {@args};
}

1;

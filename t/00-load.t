#!perl -T

use Test::More tests => 1;

BEGIN {
    use_ok( 'Mojolicious::Plugin::Prototype::MooseForm' ) || print "Bail out!\n";
}

diag( "Testing Mojolicious::Plugin::Prototype::MooseForm $Mojolicious::Plugin::Prototype::MooseForm::VERSION, Perl $], $^X" );

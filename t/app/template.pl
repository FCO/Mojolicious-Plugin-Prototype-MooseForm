#!/usr/bin/perl 
package bla;
use Moose;
has a => (is => 'ro', isa => "Num");
has e => (is => 'ro', default => "Bla");
has i => (is => 'ro');
has o => (is => 'ro');
has u => (is => 'ro');

package main;
use Mojolicious::Lite;

plugin "Mojolicious::Plugin::Prototype::MooseForm";

get "/" => sub{shift()->get_defaults("bla")} => "moose_form";

app->start;

__DATA__


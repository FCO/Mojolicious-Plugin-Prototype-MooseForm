#!/usr/bin/perl 
package bla;
use Moose;
has a => (is => 'ro');
has e => (is => 'ro');
has i => (is => 'ro');
has o => (is => 'ro');
has u => (is => 'ro');

package main;
use Mojolicious::Lite;

plugin "Mojolicious::Plugin::Prototype::MooseForm";

get "/" => sub{shift()->stash->{class} = "bla"} => "moose_form";

app->start;

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

BEGIN{ plugin "Mojolicious::Plugin::Prototype::MooseForm"; }

#get "/"  => sub{shift()->get_defaults("bla")} => "moose_form";
post "/" => sub{
   my $self = shift;
   my $obj = $self->create_object("bla");
   return $self->redirect_to("/mf") if not $obj;
   $self->render_json({ %$obj });
};

get_moose_form "/mf" => bla => {action => "/"} => "moose_form";
moose_form "/done" => "bla";

app->start;

__DATA__

@@ done.html.ep
% for my $key(sort keys %$obj) {
  <%= "$key: " . $obj->{ $key } =%><br>
%}

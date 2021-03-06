#!/usr/bin/perl 
package bla;
use Moose;
use Moose::Util::TypeConstraints;
has a => (is => 'ro', isa => "Num");
has e => (is => 'ro', default => "Bla");
has i => (is => 'ro', isa => "ArrayRef[Str]", documentation => "Doc for attr 'i'");
has o => (is => 'ro', required => 1);
has u => (is => 'ro', isa => "Maybe[Num]", documentation => "Doc for attr 'u'");
has x => (is => 'rw', isa => "Bool");
has y => (is => 'rw', isa => enum([qw/ la le li lo lu/]));

package main;
use Mojolicious::Lite;

BEGIN{ plugin "Mojolicious::Plugin::Prototype::MooseForm"; }

app->prototype_conf("required_symbol" => "<b>Obrigat&oacute;rio</b>");

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
% use Data::Dumper;
<pre>
% for my $key(sort keys %$obj) {
  <%= "$key: " . Dumper $obj->{ $key } =%><br>
%}
</pre>

#!/usr/bin/perl -t

package test_plugin;
use Moose;
has conf   => (is => 'rw');
has plugin => (is => 'rw');
sub to_test_exec{"tested"}

package app;
use Moose;
has last_helper => (is => 'rw');
sub helper {shift()->last_helper(shift)}

package main;

use Test::More tests => 14;

use_ok("Mojolicious::Plugin::Prototype::MooseForm");

my $obj = Mojolicious::Plugin::Prototype::MooseForm->new;
ok($obj->isa("Mojolicious::Plugin::Prototype::MooseForm"));

is_deeply($obj->conf, {
   prototype_list_bgcolor => [ "#E6E6FA", "#FFFFFF" ],
   prototype_bgcolor      => "#EEEEEE",
});

$obj->set_conf({a => 1, b => 2, prototype_bgcolor => "white"});

is_deeply($obj->conf, {
   prototype_list_bgcolor => [ "#E6E6FA", "#FFFFFF" ],
   prototype_bgcolor      => "white",
   a                      => 1,
   b                      => 2,
});

$obj->add_plugin("test_plugin");

is_deeply($obj->conf, $obj->{plugins}->[-1]->conf);
is($obj, $obj->{plugins}->[-1]->plugin);

my $app = app->new;
$obj->register($app);

is($app->last_helper, "get_defaults");
ok($obj->plugins->[0]->isa("Mojolicious::Plugin::Prototype::MooseForm::TemplateData"));
ok($obj->plugins->[1]->isa("Mojolicious::Plugin::Prototype::MooseForm::ClassResolver"));

$app = app->new;
$obj->register($app, {bla => "ble"});

is($app->last_helper, "get_defaults");
ok($obj->plugins->[0]->isa("Mojolicious::Plugin::Prototype::MooseForm::TemplateData"));
ok($obj->plugins->[1]->isa("Mojolicious::Plugin::Prototype::MooseForm::ClassResolver"));

is_deeply($obj->conf, {
   prototype_list_bgcolor => [ "#E6E6FA", "#FFFFFF" ],
   prototype_bgcolor      => "white",
   a                      => 1,
   b                      => 2,
   bla                    => "ble",
});

is($obj->exec("to_test_exec"),  "tested");







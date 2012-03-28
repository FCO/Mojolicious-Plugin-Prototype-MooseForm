#!/usr/bin/perl -t
package plugin_test;
use Moose;
has "error"  => (is => "rw");
has "plugin" => (is => 'rw');
sub exec{my $self = shift; my $exec = lc shift; $self->plugin->$exec(@_)}
sub can_exec{1}

package class_test;
use Moose;
has bla => (is => 'ro');
has ble => (is => 'ro', default => "ble");
has bli => (is => 'ro', isa => "Str", default => "bli");
has blo => (is => 'ro', documentation => "blo has doc", isa => "Num", default => "blo");
has blu => (is => 'ro', documentation => "blu has doc", isa => "Any", required => 1, default => "blu");

package main;
use Test::More tests => 42;

use_ok("Mojolicious::Plugin::Prototype::MooseForm::ClassResolver");

my $plugin = plugin_test->new;
my $obj = Mojolicious::Plugin::Prototype::MooseForm::ClassResolver->new({plugin => $plugin, conf => undef});
$plugin->plugin($obj);
ok($obj);

is_deeply([sort {$a->{name} cmp $b->{name}} $obj->get_class_details("class_test")],
          [
           {
            title => "Bla",
            name  => "bla",
            value => undef,
            doc   => undef,
            type  => "Any",
            req   => undef,
           },
           {
            title => "Ble",
            name  => "ble",
            value => "ble",
            doc   => undef,
            type  => "Any",
            req   => undef,
           },
           {
            title => "Bli",
            name  => "bli",
            value => "bli",
            doc   => undef,
            type  => "Str",
            req   => undef,
           },
           {
            title => "Blo",
            name  => "blo",
            value => "blo",
            doc   => "blo has doc",
            type  => "Num",
            req   => undef,
           },
           {
            title => "Blu",
            name  => "blu",
            value => "blu",
            doc   => "blu has doc",
            type  => "Any",
            req   => 1,
           },
          ], "get_class_details");

my $meta = class_test->meta;
my $bla = $meta->get_attribute("bla");

is($obj->attr_error($bla, "qwer"), undef, "->attr_error(\$bla");
is($obj->attr_error($bla, 42), undef, "->attr_error(\$bla");
is($obj->attr_error($bla, 3.14), undef, "->attr_error(\$bla");
is($obj->attr_error($bla, []), undef, "->attr_error(\$bla");
is($obj->attr_error($bla, {}), undef, "->attr_error(\$bla");
is($obj->attr_error($bla, sub{}), undef, "->attr_error(\$bla");

my $ble = $meta->get_attribute("ble");

is($obj->attr_error($ble, "qwer"), undef, "->attr_error(\$ble");
is($obj->attr_error($ble, 42), undef, "->attr_error(\$ble");
is($obj->attr_error($ble, 3.14), undef, "->attr_error(\$ble");
is($obj->attr_error($ble, []), undef, "->attr_error(\$ble");
is($obj->attr_error($ble, {}), undef, "->attr_error(\$ble");
is($obj->attr_error($ble, sub{}), undef, "->attr_error(\$ble");

my $bli = $meta->get_attribute("bli");

is($obj->attr_error($bli, "qwer"), undef, "->attr_error(\$bli");
is($obj->attr_error($bli, 42), undef, "->attr_error(\$bli");
is($obj->attr_error($bli, 3.14), undef, "->attr_error(\$bli");
ok($obj->attr_error($bli, []) =~ /^\s*Attribute \(bli\) does not pass the type constraint because: Validation failed for 'Str' with value /, "->attr_error(\$bli");
ok($obj->attr_error($bli, {}) =~ /^\s*Attribute \(bli\) does not pass the type constraint because: Validation failed for 'Str' with value /, "->attr_error(\$bli");
ok($obj->attr_error($bli, sub{}) =~ /^\s*Attribute \(bli\) does not pass the type constraint because: Validation failed for 'Str' with value /, "->attr_error(\$bli");

my $blo = $meta->get_attribute("blo");

ok($obj->attr_error($blo, "qwer") =~ /^\s*Attribute \(blo\) does not pass the type constraint because: Validation failed for 'Num' with value qwer/, "->attr_error(\$blo");
is($obj->attr_error($blo, 42), undef, "->attr_error(\$blo");
is($obj->attr_error($blo, 3.14), undef, "->attr_error(\$blo");
ok($obj->attr_error($blo, []) =~ /^\s*Attribute \(blo\) does not pass the type constraint because: Validation failed for 'Num' with value /, "->attr_error(\$blo");
ok($obj->attr_error($blo, {}) =~ /^\s*Attribute \(blo\) does not pass the type constraint because: Validation failed for 'Num' with value /, "->attr_error(\$blo");
ok($obj->attr_error($blo, sub{}) =~ /^\s*Attribute \(blo\) does not pass the type constraint because: Validation failed for 'Num' with value /, "->attr_error(\$blo");

my $blu = $meta->get_attribute("blu");

is($obj->attr_error($blu, "qwer"), undef, "->attr_error(\$blu");
is($obj->attr_error($blu, 42), undef, "->attr_error(\$blu");
is($obj->attr_error($blu, 3,14), undef, "->attr_error(\$blu");
is($obj->attr_error($blu, []), undef, "->attr_error(\$blu");
is($obj->attr_error($blu, {}), undef, "->attr_error(\$blu");
is($obj->attr_error($blu, sub{}), undef, "->attr_error(\$blu");


my $data = {
   bla => [1 .. 10],
   ble => {a => 1, b => 2},
   bli => "aeiou",
   blo => 42,
   blu => 3.14,
};

$plugin->error({});
my $new_obj = $obj->create_obj("class_test", $data);
ok($new_obj->isa("class_test"), "New obj is a class_test");
ok(not keys %{ $plugin->error });
is_deeply($new_obj->bla, [1 .. 10]);
is_deeply($new_obj->ble, {a => 1, b => 2});
is($new_obj->bli, "aeiou");
is($new_obj->blo, 42);
is($new_obj->blu, 3.14);


$data = {
   bla => [1 .. 10],
   ble => {a => 1, b => 2},
   bli => "aeiou",
   blo => "abc",
   blu => 3.14,
};

$plugin->error({});
$new_obj = $obj->create_obj("class_test", $data);
is(scalar keys %{ $plugin->error }, 1);
ok(exists $plugin->error->{blo});



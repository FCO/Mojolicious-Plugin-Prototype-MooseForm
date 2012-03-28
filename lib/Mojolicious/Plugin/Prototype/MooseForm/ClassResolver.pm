package Mojolicious::Plugin::Prototype::MooseForm::ClassResolver;
use Moose;
use v5.10;

has plugin => (is => 'ro', required => 1, handles => [qw/exec can_exec/]);
has conf   => (is => 'ro', required => 1);

sub get_class_details {
   my $self  = shift;
   my $class = shift;
   
   my $meta = $class->meta;

   map {
      my $val = $_->is_default_a_coderef
                ? $_->default->($class)
                : $_->default;
      {
         title => join(" ", map{ "\u$_" } split /_+/, $_->name),
         name  => $_->name,
         value => $val,
         doc   => $_->documentation,
         type  => $_->type_constraint || "Any",
         req   => $_->is_required,
      }
   } $meta->get_all_attributes
}

sub attr_error {
   my $self  = shift;
   my $attr  = shift;
   my $value = shift;

   eval{ $attr->verify_against_type_constraint($value) };
   if($@){
      return $1 if (split /\n/, $@)[0] =~ m{^\s*(.+)\s+at\s+.*/\w+\.pm\s+line\s+\d+\s*$};
   }
   return
}

sub create_obj {
   my $self  = shift;
   my $class = shift;
   my $data  = shift;

   my @attrs = $class->meta->get_all_attributes;

   my (%error, %attrs);
   for my $attr(@attrs) {
      my $name  = $attr->name;
      my $type  = $attr->type_constraint || "Any";

      my $value = $self->exec(get_value_for_type => $type, $name, $data);

      $attrs{ $name } = $value;
      my $err;
      $err = $self->exec(attr_error => $attr, $value);
      $error{ $name } = $err if $err;
   }
   if(keys %error) {
      $self->plugin->error({ %error });
   } else {
      return $class->new({ %attrs });
   }
}

sub get_value_for_type {
   my $self = shift;
   my $type = shift;

   my $name = "get_value_for_" . lc($type);
   return $self->exec($name => @_) if $self->can_exec($name);
   $self->exec("get_value_for_default" => @_)
}

sub get_value_for_num {shift()->get_value_for_default(@_)}
sub get_value_for_str {shift()->get_value_for_default(@_)}
sub get_value_for_any {shift()->get_value_for_default(@_)}

sub get_value_for_default {
   my $self = shift;
   my $name = shift;
   my $data = shift;

   $data->{ $name }
}

42

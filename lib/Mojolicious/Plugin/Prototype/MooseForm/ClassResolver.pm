package Mojolicious::Plugin::Prototype::MooseForm::ClassResolver;
use Moose;
use v5.10;

has plugin => (is => 'ro', required => 1, handles => [qw/exec can_exec/]);
has conf   => (is => 'ro', required => 1);

sub get_class_details {
   my $self   = shift;
   my $class  = shift;
   my $params = shift || {};
   
   my $meta = $class->meta;

   map {
      my $oval = $params->{$_->name}; 
      my $val = $oval
                ? $oval
                : $_->is_default_a_coderef
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
      return { %attrs }
   } else {
      return $class->new({ %attrs });
   }
}

sub create_exec_name {
   my $self = shift;
   my $type = join "_of_", map{ lc $_ } @_;


   "get_value_for_" . $type;
}

sub get_value_for_type {
   my $self = shift;
   my $type = lc shift;

   my $ret;
   my @val = $self->exec( separate_value => $type);
   for( reverse 0 .. $#val ) {
      my $name = $self->create_exec_name(@val[ 0 .. $_ ]);
      my $subtype = $self->exec(type_reconstruct => @val[ $_ + 1 .. $#val ]);
      $ret = $self->exec($name => $subtype, @_) if $self->can_exec($name);
   }
   $ret = $self->exec("get_value_for_default" => $type, @_) if not defined $ret;
   $ret
}

sub get_value_for_arrayref {
   my $self = shift;
   my $type = shift;
   my $name = shift;
   my $data = shift;

   my @ret;
   my $count = 1;
   my $new_name = $name . $count++;
   while( exists $data->{ $new_name } ) { 
      my $val = $self->get_value_for_type($type, $new_name, $data, @_);
      push @ret, $val;
      $new_name = $name . $count++;
   }
   [ @ret ]
}
sub get_value_for_maybe {
   my $self = shift;
   $self->get_value_for_type(@_) || undef
}
sub get_value_for_num   {shift()->get_value_for_default(@_) || undef}
sub get_value_for_str   {shift()->get_value_for_default(@_) || undef}
sub get_value_for_any   {shift()->get_value_for_default(@_) || undef}

sub get_value_for_default {
   my $self = shift;
   my $type = shift;
   my $name = shift;
   my $data = shift;

   $data->{ $name }
}

42

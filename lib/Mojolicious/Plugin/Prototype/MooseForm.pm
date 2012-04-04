package Mojolicious::Plugin::Prototype::MooseForm;
use Mojo::Base 'Mojolicious::Plugin';
use Mojolicious::Plugin::Prototype::MooseForm::ClassResolver;
use Mojolicious::Plugin::Prototype::MooseForm::TemplateData;
use v5.10;
use Moose;
use Carp qw/croak/;

our $VERSION = '0.01';

has conf    => (is => 'rw', lazy => 1, isa => "HashRef", default => sub{{
   prototype_list_bgcolor        => [ "#E6E6FA", "#FFFFFF" ],
   prototype_bgcolor             => "#EEEEEE",
   prototype_submit_label        => "OK",
   prototype_required_color      => "red",
   prototype_required_symbol     => "*",
   prototype_error_bgcolor       => "#ffaaaa",
   prototype_error_border_color  => "red",
   prototype_error_border_width  => "1px",
   prototype_input_error_color   => "red",
   prototype_default_error_msg   => "ERROR: Value don't match the type",

}});
has plugins => (is => 'ro', lazy => 1, default => sub{ [] });
has error   => (is => 'rw', isa => "HashRef");
has app     => (is => 'rw');

after error => sub {
   my $self = shift;
   $self->{ error } = {} if not @_
};

sub plugin_init {
   my $self = shift;
   return {
            plugin => $self,
            conf   => $self->conf,
          }
}

sub set_conf {
   my $self = shift;
   my $conf = shift;

   my $sconf = $self->conf;
   for my $key(keys %$conf) {
     $sconf->{ $key } = $conf->{ $key };
   }
}

sub can_exec {
   my $self    = shift;
   my $exec    = shift;
   my $plugins = $self->plugins;

   for my $plug(@$plugins) {
      return 1 if $plug->can($exec)
   }
   return 1 if $self->can($exec);
   0
}

sub exec {
   my $self    = shift;
   my $exec    = shift;
   my $plugins = $self->plugins;

   for my $plug(@$plugins) {
      if($plug->can($exec)) {
         return $plug->$exec(@_);
      }
   }
   if( $self->can($exec) ) {
      return $self->$exec(@_);
   }
   croak "Can not find '$exec' on plugins."
}

sub add_plugin {
   my $self   = shift;
   my $plugin = shift;

   unshift @{ $self->plugins }, $plugin->new( $self->plugin_init );
   push @{ $self->app->renderer->classes }, $plugin if $self->app && $self->app->can("renderer");
   push @{ $self->app->static->classes }, $plugin if $self->app && $self->app->can("renderer");
}

sub separate_value {
   my $self  = shift;
   my $value = shift;

   return "none" if not defined $value;

   my @ret;
   if(my ($first, $second) = $value =~ /^\s*(\w+)\s*\[\s*(.*?)\s*\]\s*$/) {
      push @ret, $first, $self->separate_value( $second );
   } else {
      push @ret, $value;
   }
   @ret
}

sub create_template_name {
      my $self   = shift;
      my $action = lc shift;
      my $type   = lc shift;
      my $value  = join "_of_", map { lc $_ } @_;

      #$self->app->log->debug("***** TESTING: moose_form_template_${action}_${type}_${value}");
      "moose_form_template_${action}_${type}_${value}"
}

sub type_reconstruct {
   my $self  = shift;
   my $first = shift;

   my $ret;
   if( not $first ) {
   } elsif( not @_ ) {
      $ret = $first;
   } else {
      $ret = "$first\[" . $self->type_reconstruct(@_) . "]"
   }
   $ret
}

sub register { 
   my $self = shift;
   my $app  = shift;
   my $conf = shift;

   $self->app( $app ) ;

   $self->set_conf($conf);
   $self->add_plugin( "Mojolicious::Plugin::Prototype::MooseForm::ClassResolver" );
   $self->add_plugin( "Mojolicious::Plugin::Prototype::MooseForm::TemplateData" );
   my $pl_self = $self;

   $app->helper(prototype_conf => sub{
      my $self = shift;
      my $key  = shift;

      $key = "prototype_" . $key unless $key =~ s/^\+//;
      if(@_) {
         $pl_self->conf->{$key} = shift;
      } else {
         return $pl_self->conf->{$key};
      }
   });

   $app->helper("moose_form_get_conf" => sub {
      $pl_self->conf;
   });

   $app->helper("moose_form_template_for" => sub {
      my $self   = shift;
      my $action = lc shift;
      my $type   = lc shift;
      my $value  = lc shift;

      my $controller = $self;
      my $renderer   = $self->app->renderer;

      my @val = $pl_self->separate_value($value);
      my @ret;
      for(reverse 0 .. $#val) { 
         my $name = $pl_self->create_template_name($action, $type, @val[ 0 .. $_ ]);
         if(eval { $renderer->render($controller, { template => $name, subtype => $pl_self->type_reconstruct( @val[ $_ + 1 .. $#val ] ) }) } or $@) { 
            push @ret, $name, subtype => $pl_self->type_reconstruct(@val[ $_ + 1 .. $#val ] );
            last;
         }
      }
      if( not @ret ) {
         my @other = ( $action, $type, "default" );
         push @ret, $pl_self->create_template_name(@other), subtype => undef
      }
      @ret
   });

   $app->helper("get_defaults" => sub {
      my $self  = shift;
      my $class = shift;
      my @defaults = $pl_self->exec(get_class_details => $class, $self->flash("params"));
      $self->stash->{attributes} = [ @defaults ];
      $self->stash->{class}      = $class;
      $self->stash->{error}      = $self->flash("error");
      $self->stash->{action}     = "";
      $self->flash(error => {})
   });

   $app->helper("create_object" => sub {
      my $self  = shift;
      my $class = shift;
      my $params = {};
      $params->{$_} = $self->param($_) for $self->param;

      my $obj = $pl_self->exec(create_obj => $class, $params);
      my $error = $pl_self->error;
      if(keys %$error) {
         $self->flash(params => $obj);
         for my $key(keys %$error) {
            $app->log->debug("ERROR: " . $error->{ $key }) if $error->{ $key } ;
         }
         $self->flash(error => $error);
         return;
      }
      return $obj
   });
   $app->routes->add_shortcut("get_moose_form" => sub{
      my $self  = shift;
      my $url   = shift;
      my $class = shift;

      my $code   = ( grep{ref eq "CODE"} @_ )[ 0 ] ;
      my $action = ( map{$_->{ action }} grep {ref eq "HASH" and exists $_->{action}} @_ )[ 0 ] ;

      $self->get($url, sub{
         my $self = shift;
         $self->get_defaults($class);
         $self->stash->{action} = $action if $action;
         $self->$code(@_) if defined $code;
      }, grep{ref ne "CODE"} @_);
   });
   $app->routes->add_shortcut("moose_form" => sub{
      my $self  = shift;
      my $url   = shift;
      my $class = shift;

      my $code   = ( grep{ref eq "CODE"} @_ )[ 0 ] ;
      my $action = ( map{$_->{ action }} grep {ref eq "HASH" and exists $_->{action}} @_ )[ 0 ] ;
      my ($pname, $gname) = reverse grep{not ref} @_;

      my $purl = $action || $url;

      $self->get_moose_form($url, $class, ( $gname || "moose_form" ) );
      $self->post($purl, sub{
         my $self = shift;
         $self->stash->{ obj } = $self->create_object($class);
         return $self->redirect_to($url) if not $self->stash->{ obj };
         $self->stash->{action} = $action;
         $self->$code($self->stash->{ obj }, @_) if defined $code;
      } => $pname => grep{ref and ref ne "CODE"} @_);
   });

   *main::get_moose_form = sub{$app->routes->get_moose_form(@_)};
   *main::moose_form     = sub{$app->routes->moose_form(@_)};

   $app->routes->get("/css/moose_form" => "moose_form");
}

42

__END__

=head1 NAME

Mojolicious::Plugin::Prototype::MooseForm - A Mojolicious Plugin to make it eazy to create Form prototype from Moose Classes.

=head1 VERSION

Version 0.01

=cut



=head1 SYNOPSIS

Quick summary of what the module does.

Perhaps a little code snippet.

    package My::Class;
    use Moose;
    
    has my_string               => (is => 'rw', isa => "Str",                  documentation => "This is a string and it can't be undefined.");
    has my_number               => (is => 'rw', isa => "Num",                  documentation => "This is a number and it can't be undefined.");
    has maybe_a_string          => (is => 'rw', isa => "Maybe[Str]",           documentation => "This is a string but can be undefined.");
    has maybe_a_number          => (is => 'rw', isa => "Maybe[Num]",           documentation => "This is a number but can be undefined.");
    has array_of_strings        => (is => 'rw', isa => "ArrayRef[Str]",        documentation => "This is a array of strings.");
    has array_of_numbers        => (is => 'rw', isa => "ArrayRef[Num]",        documentation => "This is a array of numbers.");
    has array_of_maybe_strings  => (is => 'rw', isa => "ArrayRef[Maybe[Str]]", documentation => "This is a array of strings.");
    has array_of_maybe_numbers  => (is => 'rw', isa => "ArrayRef[Maybe[Num]]", documentation => "This is a array of numbers.");

    
    package main;
    
    use Mojolicious::Lite;
    
    BEGIN{ plugin "Mojolicious::Plugin::Prototype::MooseForm" }
    
    moose_form "/" => "My::Class" => sub {
       my $self = shift;
       my $obj  = shift;

       $self->render_json($obj);
    } => "response";
    
    app->start;

=head1 EXPORT

A list of functions that can be exported.  You can delete this section
if you don't export anything, such as for a purely object-oriented module.

=head1 SUBROUTINES/METHODS

=head2 function1

=cut

=head2 function2

=cut

=head1 AUTHOR

Fernando Correa de Oliveira, C<< <fco at cpan.org> >>

=head1 BUGS

Please report any bugs or feature requests to C<bug-mojolicious-plugin-prototype-mooseform at rt.cpan.org>, or through
the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=Mojolicious-Plugin-Prototype-MooseForm>.  I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.




=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc Mojolicious::Plugin::Prototype::MooseForm


You can also look for information at:

=over 4

=item * RT: CPAN's request tracker (report bugs here)

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=Mojolicious-Plugin-Prototype-MooseForm>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/Mojolicious-Plugin-Prototype-MooseForm>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/Mojolicious-Plugin-Prototype-MooseForm>

=item * Search CPAN

L<http://search.cpan.org/dist/Mojolicious-Plugin-Prototype-MooseForm/>

=back


=head1 ACKNOWLEDGEMENTS


=head1 LICENSE AND COPYRIGHT

Copyright 2012 Fernando Correa de Oliveira.

This program is free software; you can redistribute it and/or modify it
under the terms of either: the GNU General Public License as published
by the Free Software Foundation; or the Artistic License.

See http://dev.perl.org/licenses/ for more information.


=cut

1; # End of Mojolicious::Plugin::Prototype::MooseForm

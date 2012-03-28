package Mojolicious::Plugin::Prototype::MooseForm;
use Mojo::Base 'Mojolicious::Plugin';
use Mojolicious::Plugin::Prototype::MooseForm::ClassResolver;
use Mojolicious::Plugin::Prototype::MooseForm::TemplateData;
use v5.10;
use Moose;
use Carp;

our $VERSION = '0.01';

has conf    => (is => 'rw', lazy => 1, isa => "HashRef", default => sub{{
   prototype_list_bgcolor => [ "#E6E6FA", "#FFFFFF" ],
   prototype_bgcolor      => "#EEEEEE",
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
      return $plug->$exec(@_) if $plug->can($exec)
   }
   return $self->$exec(@_) if $self->can($exec);
   croak "Can not find '$exec' on plugins.";
}

sub add_plugin {
   my $self   = shift;
   my $plugin = shift;

   unshift @{ $self->plugins }, $plugin->new( $self->plugin_init );
   push @{ $self->app->renderer->classes }, $plugin if $self->app && $self->app->can("renderer");
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

   $app->helper("js_event_for" => sub {
      my $self  = shift;
      my $event = shift;
      my $what  = shift;
      my $value = lc shift;
      my $controller = $self;
      my $renderer   = $self->app->renderer;
      $value = "default" unless $renderer->render($controller, { template => "js_${event}_for_${what}_${value}" });
      "js_${event}_for_${what}_${value}"
   });

   $app->helper("template_for_type" => sub {
      my $self = shift;
      my $type = lc shift;
      my $controller = $self;
      my $renderer   = $self->app->renderer;
      $type = "default" unless $renderer->render($controller, { template => "template_for_type_$type" });
      "template_for_type_$type"
   });

   $app->helper("get_defaults" => sub {
      my $self  = shift;
      my $class = shift;
      my @defaults = $pl_self->exec(get_class_details => $class);
      $self->stash->{attributes} = [ @defaults ];
      $self->stash->{class}      = $class;
   });
}

42

__END__

=head1 NAME

Mojolicious::Plugin::Prototype::MooseForm - The great new Mojolicious::Plugin::Prototype::MooseForm!

=head1 VERSION

Version 0.01

=cut



=head1 SYNOPSIS

Quick summary of what the module does.

Perhaps a little code snippet.

    use Mojolicious::Plugin::Prototype::MooseForm;

    my $foo = Mojolicious::Plugin::Prototype::MooseForm->new();
    ...

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

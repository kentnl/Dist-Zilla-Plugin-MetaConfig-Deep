use 5.006;    # our
use strict;
use warnings;

package Dist::Zilla::Plugin::MetaConfig::Deep;

our $VERSION = '0.001000';

# ABSTRACT: Experimental enhancements to MetaConfig

our $AUTHORITY = 'cpan:KENTNL'; # AUTHORITY

use Moose qw( with );

with 'Dist::Zilla::Role::MetaProvider';

sub _metadata_perl { { version => $] } }

sub _metadata_zilla {
  my ($self) = @_;

  my $config = $self->zilla->dump_config;
  my $composed = $self->_metadata_class_composes($self->zilla);

  return {
    class   => $self->zilla->meta->name,
    version => $self->zilla->VERSION,
    ( keys %$config ? ( config => $config ) : () ),
    ( keys %$composed ? ( x_composes => $composed ) : () ),
  };
}

sub _metadata_plugins {
  my ($self) = @_;
  return [ map { $self->_metadata_plugin($_) } @{ $self->zilla->plugins } ];
}

sub _metadata_class_composes {
  my ( $self, $plugin ) = @_;

  my $composed = {
  
  };
  $composed->{x_for} = $plugin->meta->name;
  for my $component ( $plugin->meta->calculate_all_roles_with_inheritance ) {
    next if $component->name =~ /\|/;    # skip unions.
    $composed->{ $component->name } = $component->name->VERSION;
  }
  for my $component ( $plugin->meta->linearized_isa ) {
    next if $component->meta->name =~ /\|/;    # skip unions.
    $composed->{ $component->meta->name } = $component->meta->name->VERSION;
  }

  return $composed;
}

sub _metadata_plugin {
  my ( $self, $plugin ) = @_;
  my $config   = $plugin->dump_config;
  my $composed = $self->_metadata_class_composes($plugin);
  return {
    class   => $plugin->meta->name,
    name    => $plugin->plugin_name,
    version => $plugin->VERSION,
    ( keys %$config ? ( config => $config ) : () ),
    ( keys %$composed ? ( x_composes => $composed ) : () ),
  };
}

sub metadata {
  my ($self) = @_;

  my $dump = {};

  $dump->{zilla}   = $self->_metadata_zilla;
  $dump->{perl}    = $self->_metadata_perl;
  $dump->{plugins} = $self->_metadata_plugins;

  return { x_Dist_Zilla => $dump };
}

__PACKAGE__->meta->make_immutable;
no Moose;

1;

__END__

=pod

=encoding UTF-8

=head1 NAME

Dist::Zilla::Plugin::MetaConfig::Deep - Experimental enhancements to MetaConfig

=head1 VERSION

version 0.001000

=head1 DESCRIPTION

This module serves as an experimental space for features I think the core MetaConfig I<should>
provide, but in a state of uncertainty about how they should be implemented.

The objective is to extract more metadata about plugins without plugins having to percolate
hand-written adjustments system-wide to get a useful interface.

=head2 Composition Data

This exposes data about the roles and parent classes, and their respective versions in play
on a given plugin, to give greater depth for problem diagnosis.

=head1 AUTHOR

Kent Fredric <kentnl@cpan.org>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2015 by Kent Fredric <kentfredric@gmail.com>.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut

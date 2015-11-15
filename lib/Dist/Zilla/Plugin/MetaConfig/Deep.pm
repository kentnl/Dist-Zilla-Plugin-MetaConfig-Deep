use 5.006;  # our
use strict;
use warnings;

package Dist::Zilla::Plugin::MetaConfig::Deep;

our $VERSION = '0.001000';

# ABSTRACT: Experimental enhancements to MetaConfig

our $AUTHORITY = 'cpan:KENTNL'; # AUTHORITY

use Moose;
extends 'Dist::Zilla::Plugin::MetaConfig';

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

=head1 AUTHOR

Kent Fredric <kentnl@cpan.org>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2015 by Kent Fredric <kentfredric@gmail.com>.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut

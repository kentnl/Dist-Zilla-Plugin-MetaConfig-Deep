use 5.006;  # our
use strict;
use warnings;

package Dist::Zilla::Plugin::MetaConfig::Deep;

our $VERSION = '0.001000';

# ABSTRACT: Experimental enhancements to MetaConfig

# AUTHORITY

use Moose;
extends 'Dist::Zilla::Plugin::MetaConfig';

__PACKAGE__->meta->make_immutable;
no Moose;

1;

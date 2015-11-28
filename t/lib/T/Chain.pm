use 5.006;    # our
use strict;
use warnings;

package T::Chain;

# ABSTRACT: A prototype for a Test::Chain

# AUTHORITY

sub metachain {
  require T::Chain::Meta;
  T::Chain::Meta::metachain( $_[0] );
}

sub new     { $_[0]->metachain->create_instance(@_) }
sub matches { $_[0]->metachain->instance_matches(@_) }

1;


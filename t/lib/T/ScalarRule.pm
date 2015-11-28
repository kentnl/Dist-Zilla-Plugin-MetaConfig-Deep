use strict;
use warnings;

package T::ScalarRule;

use parent 'T::Chain';

use Exporter 5.57 qw(import);

our @EXPORT_OK = ('is_scalar');

sub is_scalar {
  if ( scalar @_ == 2 ) {
    my ( $label, $code ) = @_;
    my $rule = __PACKAGE__->new( { label => $label } );
    $code->($rule);
    return $rule;
  }
  if ( scalar @_ == 1 ) {
    my $rule = __PACKAGE__->new( { label => $_[0] } );
    return $rule;
  }
}

__PACKAGE__->metachain->add_rule(
  'defined' => sub {
    return sub {
      my ( $context, $got ) = @_;
      return $context->ok( 1, 'is defined' ) if defined $got;
      return $context->ok( 0, 'is defined' );
    };
  }
);
__PACKAGE__->metachain->add_rule(
  'nonref' => sub {
    return sub {
      my ( $context, $got ) = @_;
      return $context->ok( 1, 'is not a ref' ) unless ref $got;
      return $context->ok( 0, 'is not a ref' );
    };
  }
);

__PACKAGE__->metachain->add_rule(
  'equals' => sub {
    my ($value) = @_;
    return sub {
      my ( $context, $got ) = @_;
      return $context->ok( $got eq $value, 'equals ' . $value );
      }
  }
);

1;

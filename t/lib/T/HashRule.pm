use strict;
use warnings;

package T::HashRule;

use parent 'T::Chain';

use Exporter 5.57 qw(import);

our @EXPORT_OK = ('is_hash');

sub is_hash {
  if ( scalar @_ == 2 ) {
    my ( $label, $code ) = @_;
    my $rule = __PACKAGE__->new( { label => $label } );
    $rule->_is_hash;
    $code->($rule);
    return $rule;
  }
  if ( scalar @_ == 1 ) {
    my $rule = __PACKAGE__->new( { label => $_[0] } );
    $rule->_is_hash;
    return $rule;
  }
}

__PACKAGE__->metachain->add_rule(
  '_is_hash' => sub {
    return sub {
      my ( $context, $got ) = @_;
      return $context->ok( 1, 'is of reftype hash' ) if 'HASH' eq ref $got;
      return $context->ok( 0, 'is not of reftype hash' );
    };
  }
);
__PACKAGE__->metachain->add_rule(
  'has_key' => sub {
    my ( $key, $subrule ) = @_;
    if ( not $subrule ) {
      return sub {
        my ( $context, $got ) = @_;
        if ( not exists $got->{$key} ) {
          return $context->ok( 0, 'hash does not contain ' . $key );
        }
        $context->ok( 1, 'hash contains key ' . $key );
      };
    }
    if ( not $subrule->can('matches') ) {
      die "Inappropriate subrule";
    }
    return sub {
      my ( $context, $got ) = @_;
      if ( not exists $got->{$key} ) {
        return $context->ok( 0, 'hash does not contain ' . $key );
      }
      $context->ok( 1, 'hash contains key ' . $key );
      return $subrule->matches( $got->{$key}, $context );
    };
  }
);
__PACKAGE__->metachain->add_rule(
  'keys_are' => sub {
    my ($key_array) = @_;
    my $wanted_keys = {};
    @{$wanted_keys}{@_} = (1) x scalar @_;
    return sub {
      my ( $context, $got ) = @_;
      my $available = {};
      @{$available}{ keys %{$got} } = (1) x keys %{$got};
      $context->group(
        'keys_are' => sub {
          my $ret = $context->group(
            'required_keys' => sub {
              for my $key ( sort keys %{$wanted_keys} ) {
                if ( exists $available->{$key} ) {
                  delete $available->{$key};
                  $context->ok( 1, "Has required key $key" );
                  next;
                }
                return $context->ok( 0, "Lacks required key $key" );
              }
            }
          );
          return $ret if not $ret;
          if ( keys %{$available} ) {
            return $context->ok( 1, "No excess keys" );
          }
          $context->ok( 0, ( scalar keys %{$available} ) . " excess keys" );
          return 0;
        }
      );
    };
  }
);
1;

use strict;
use warnings;

package T::ArrayRule;

use parent 'T::Chain';

use Exporter 5.57 qw(import);

our @EXPORT_OK = ('is_array');

sub is_array {
  if ( scalar @_ == 2 ) {
    my ( $label, $code ) = @_;
    my $rule = __PACKAGE__->new( { label => $label } );
    $rule->_is_array;
    $code->($rule);
    return $rule;
  }
  if ( scalar @_ == 1 ) {
    my $rule = __PACKAGE__->new( { label => $_[0] } );
    $rule->_is_array;
    return $rule;
  }
}

__PACKAGE__->metachain->add_rule(
  '_is_array' => sub {
    return sub {
      my ( $context, $got ) = @_;
      return $context->ok( 1, 'is of reftype array' ) if 'ARRAY' eq ref $got;
      return $context->ok( 0, 'is not of reftype array' );
    };
  }
);
__PACKAGE__->metachain->add_rule(
  'has_entry' => sub {
    my ($subrule) = @_;
    if ( not $subrule->can('matches') ) {
      die "Cant do `matches`";
    }
    return sub {
      my ( $context, $got ) = @_;
      my (@got_items) = @{$got};
      $context->group(
        'has_entry' => sub {
          my $super_context = T::Chain::Result->new( { silent => 1 } );

          for my $item_no ( 0 .. $#got_items ) {
            my $mock_context = T::Chain::Result->new( { silent => 1 } );
            $mock_context->note( "$item_no of $#got_items: " . $context->explain( $got_items[$item_no] ) );
            my $matches = $subrule->matches( $got_items[$item_no], $mock_context );
            $super_context->adopt( "item $item_no/$#got_items matches subrule", $matches, $mock_context );
            if ($matches) {
              $context->adopt( "item $item_no/$#got_items matches subrule", 1, $mock_context );
              $context->ok( 1, "item $item_no/$#got_items matches subrule" );
              return 1;
            }
          }
          $context->adopt( "An item matches subrule", 0, $super_context );
        }
      );
    };
  }
);
1;

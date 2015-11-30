use 5.006;    # utf8
use strict;
use warnings;

package T::Test;

# ABSTRACT: An abstract node representing a comparison result

# AUTHORITY

our %HAS = (
  subject       => undef,
  rule          => undef,
  result        => undef,
  result_reason => undef,
  children      => sub { [] },
);

our $METACLASS = T::Test::Meta->new( \%HAS );

sub new           { $METACLASS->CREATE(@_) }
sub subject       { $METACLASS->ATTR_GET( $_[0], 'subject' ) }
sub rule          { $METACLASS->ATTR_GET( $_[0], 'rule' ) }
sub result        { $METACLASS->ATTR_GET( $_[0], 'result' ) }
sub result_reason { $METACLASS->ATTR_GET( $_[0], 'result_reason' ) }
sub children      { @{ $METACLASS->ATTR_GET( $_[0], 'children' ) } }

sub pass {
  $METACLASS->ATTR_SET( $_[0], 'result',        1 );
  $METACLASS->ATTR_SET( $_[0], 'result_reason', $_[1] );
}

sub fail {
  $METACLASS->ATTR_SET( $_[0], 'result',        0 );
  $METACLASS->ATTR_SET( $_[0], 'result_reason', $_[1] );
}
sub ok {
  $METACLASS->ATTR_SET( $_[0], 'result',        $_[1] );
  $METACLASS->ATTR_SET( $_[0], 'result_reason', $_[2] );
}

sub new_child {
  my $child = $METACLASS->CREATE(@_);
  $METACLASS->ATTR_PUSH( $_[0], 'children', $child );
  return $child;
}

{

  package T::Test::Meta;

  use Scalar::Util qw( blessed );

  sub new { bless PARAM_HASH( $_[1] ), CLASS( $_[0] ) }

  sub CREATE {
    return bless PARAM_HASH( $_[2] ), CLASS( $_[1] );
  }

  sub PARAM_HASH {
    { %{ $_[0] || {} } }
  }
  sub CLASS { blessed $_[0] || $_[0] }
  sub INSTANCE { blessed $_[0] ? $_[0] : die "not an instance" }

  sub ATTR_SET {
    my ( $meta, $instance, $attrname, $value ) = @_;
    $instance->{$attrname} = $value;
    return $instance;
  }

  sub ATTR_GET {
    my ( $meta, $instance, $attrname ) = @_;
    if ( $meta->{$attrname} and not exists $instance->{$attrname} ) {
      $instance->{$attrname} = $meta->{$attrname}->($instance);
    }
    return $instance->{$attrname};
  }

  sub ATTR_MUTATE {
    my ( $meta, $instance, $attrname, $maybe_value ) = @_;
    if ($maybe_value) {
      $meta->ATTR_SET( $instance, $attrname, $maybe_value );
    }
    return $meta->ATTR_GET( $invocant, $attribute );
  }

  sub ATTR_PUSH {
    my ( $meta, $invocant, $attrname, $value ) = @_;
    push @{ $instance->{$attrname} }, $value;
    return $instance;
  }
}
1;


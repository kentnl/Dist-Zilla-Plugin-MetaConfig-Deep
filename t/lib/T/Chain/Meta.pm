use 5.006;
use strict;
use warnings;

package T::Chain::Meta;

our %METACHAINS;

use Scalar::Util qw( blessed );

my $chain_id = 0;

sub create_instance {
  my ( $metachain, $class_arg, $payload ) = @_;
  my $class = blessed $class_arg || $class_arg;
  my $object = bless { %{ $payload || {} } }, $class_arg;
  $object->{rules} ||= [];
  $object->{label} ||= do { "Unlabelled chain " . ++$chain_id };
  return $object;
}

sub metachain {
  my $class = blessed $_[0] || $_[0];
  return ( $METACHAINS{$class} ||= __PACKAGE__->new( { class => $class } ) );
}

sub new { bless { %{ $_[1] || {} } }, $_[0] }
sub class { $_[0]->{class} }

sub add_rule_to_instance {
  my ( $meta, $rule, $instance ) = @_;
  push @{ $instance->{rules} }, $rule;
  return $meta;
}

sub instance_matches {
  my ( $meta, $instance, $got, $result_set ) = @_;
  $result_set ||= do {
    require T::Chain::Result;
    T::Chain::Result->new();
  };
  $result_set->group(
    $instance->{label},
    sub {
      $result_set->note( "Studying: " . $result_set->explain($got) );
      for my $rule ( @{ $instance->{rules} || [] } ) {
        my $ok = $rule->( $result_set, $got );
        next if $ok;
        return $ok;
      }
      return 1;
    }
  );
}

sub add_rule {
  my ( $meta, $name, $code ) = @_;
  my $class = $meta->class;
  eval <<"EOF";
package ${class};
sub ${class}::${name} {
  my ( \$self, \@user_args ) = \@_;
  \$self->metachain->add_rule_to_instance(\$code->( \@user_args ), \$self);
  return \$self;
}
EOF
  die $@ if $@;

  return $meta;
}

1;

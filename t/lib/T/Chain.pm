use 5.006;    # our
use strict;
use warnings;

package T::Chain;

# ABSTRACT: A prototype for a Test::Deep::Chain

# AUTHORITY

use Test::Deep ();
use Test::Deep::Filter ();

use parent 'Test::Deep::Cmp';

sub init {
  my ($self) = @_;
  $self->{rules} = [];
}

sub descend {
  my ( $self, $got ) = @_;
  my $context = T::Chain::Context->new();
  for my $rule ( @{ $self->{rules} } ) {
    my ( $ok, $stack ) = Test::Deep::cmp_details( $got , $rule);
    $context->trace( $rule, $ok , $stack );
    $self->data->{context} = $context;
    return 0 unless $ok;
  }
  return 1;
}

sub _append_rule {
  my ( $self, $rule ) = @_;
  push @{ $self->{rules} }, $rule; 
  return $self;
}
sub _add_rule {
  my ( $self, $rule_name, $rule_code ) = @_;
  push @{ $self->{rules} }, T::Chain::Rule->new( $rule_name, $rule_code );
  return $self;
}
sub _add_branch_rule {
  my ( $self, $rule_name, $rule_code, $filter_code, $branch_rule ) = @_;
  $self->_add_rule( $rule_name, $rule_code );
  $self->_append_rule( Test::Deep::Filter::filter( $filter_code, Test::Deep::wrap($branch_rule) ));
  return $self;
}
sub diagnostics {
  my ( $self, $where, $last ) = @_;
  die if not exists $last->{context};

  my $error = Test::Deep::deep_diag( $last->{context}->last->{stack} );
  $error .= "\nTrace:\n";
  for my $item ( $last->{context}->items ) {
    if ( $item->{rule}->can('name') ) {
      $error .= " - " . $item->{rule}->name . "\n";
      next;
    }
    $error .= " - " . $item->{rule} . "\n";
  }
  return $error;
}
{
  package T::Chain::Rule;

  use parent 'Test::Deep::Cmp';
  sub init {
    my ( $self, $name, $code ) = @_;
    $self->{name} = $name;
    $self->{code} = $code;
  }
  sub name { $_[0]->{name} }
  sub code { $_[0]->{code} }
  sub descend {
    my ( $self, $got ) = @_;
    my ( $ok, $reason ) = $self->code->( $got );
    if ( $reason ) {
      $self->data->{diag} = $reason;
    }
    return $ok;
  }
  sub diagnostics {
    return $_[0]->data->{diag};
  }
}
{
  package T::Chain::Rule::Leaf;
  use parent 'T::Chain';
  sub init {
    my ( $self, $name, $code, $leaf ) = @_;
    $self->{name} = $name;
    $self->{code} = $code;
    $self->{leaf} = $leaf;
  }
  sub name {
    "when " . $_[0]->{name} . " then ";
  }
  sub code { $_[0]->{code} }
  sub leaf { $_[0]->{leaf} }

}
{
  package T::Chain::Context;
  sub new { bless {%{$_[1] ||= {}}}, $_[0] };
  sub trace {
    my ( $self, $rule, $ok, $stack ) = @_;
    push @{ $self->{trace} }, {
        rule => $rule, 
        ok => $ok,
        stack => $stack
    };
  }
  sub items {
    return @{$_[0]->{trace}};
  }
  sub last {
    return $_[0]->{trace}->[-1];
  }
}
1;


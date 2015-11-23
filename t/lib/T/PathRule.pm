use strict;
use warnings;

package T::PathRule;
use Path::Tiny qw(path);
use parent 'Test::Deep::Cmp';

use Exporter 5.57 qw( import );
our @EXPORT_OK = (qw( is_path ));

sub is_path {
  return __PACKAGE__->new();
}

sub init {
  $_[0]->{rules} = [];
}

sub match {
  my ( $self, $target ) = @_;
  for my $rule ( @{ $self->{rules} } ) {
    my ( $result, $reason ) = $rule->($target);
    next if $result;
    return ( $result, $reason );
  }
  return 1;
}

sub descend {
  my ( $ok, $diag ) = $_[0]->match( $_[1] );
  $_[0]->data->{diag} = $diag;
  return $ok;
}

sub diagnostics {
  my $self = shift;
  my ( $where, $last ) = @_;

  my $error = $last->{diag};
  my $data  = Test::Deep::render_val( $last->{got} );
  my $path  = Test::Deep::render_val( defined $last->{got} ? "$last->{got}" : undef );
  my $diag  = "";
  $diag .= "Path: $path";
  if ( $data ne $path ) {
    $diag .= " ( $data )";
  }
  $diag .= "\nSource: $where\n";

  if ( defined($error) ) {
    $diag .= "Result: $error";
  }
  else {
    $diag .= "Result Unspecified";
  }

  return $diag;
}

sub dir {
  push @{ $_[0]->{rules} }, sub {
    return 1 if -d $_[0];
    return ( 0, "$_[0] is not a directory" );
  };
  return $_[0];
}

sub file {
  push @{ $_[0]->{rules} }, sub {
    return 1 if !-d $_[0];
    return ( 0, "$_[0] is not a file" );
  };
  return $_[0];
}

sub readable {
  push @{ $_[0]->{rules} }, sub {
    return 1 if -r $_[0];
    return ( 0, "$_[0] is not readable" );
  };
  return $_[0];
}

sub has_child {
  my ( $self, @path ) = @_;
  my $rule = Test::Deep::wrap( pop @path );
  if ( not $rule->can('match') ) {
    die "has_child rules must be path matches";
  }
  push @{ $_[0]->{rules} }, sub {
    my $child = path( $_[0] )->child(@path);
    return $rule->match($child);
  };
  return $_[0];
}


use 5.006;
use strict;
use warnings;

package T::Chain::Result;
use Data::Dumper qw(Dumper);
use Term::ANSIColor qw( colored );
sub new { bless { %{ $_[1] || {} } }, $_[0] }

sub explain {
  my ( $self, $thing ) = @_;
  local $Data::Dumper::Terse     = 1;
  local $Data::Dumper::Indent    = 0;
  local $Data::Dumper::Quotekeys = 0;
  local $Data::Dumper::Maxdepth  = 2;
  local $Data::Dumper::Sortkeys  = 1;
  my $xthing = Dumper($thing);
  if ( 100 < length $xthing ) {
    my $head = substr( $xthing, 0, 100 - 5 );
    my $tail = substr( $xthing, length($xthing) - 1, 1 );
    return "${head}...${tail}";
  }
  return $xthing;
}

sub note {
  my ( $self, $note ) = @_;
  push @{ $self->{results} }, [ 'NOTE', $note, $self->{path} ];
}

sub ok {
  my ( $self, $ok, $reason ) = @_;
  push @{ $self->{results} }, [ 'OK', $ok, $reason, $self->{path} ];
  if ( not $self->{silent} ) {
    require Test::Builder;
    my $builder = Test::Builder->new();
    $builder->ok( $ok, _pp_path( [ @{ $self->{path} || [] }, $reason ] ) );
    if ( !$ok ) {
      $builder->diag( $self->trace );
    }
  }
  return $ok;
}

sub group {
  my ( $self, $group_name, $code ) = @_;
  my $children = [];
  my $group = [ 'GROUP', 0, $group_name, $self->{path}, $children ];
  push @{ $self->{results} }, $group;
  {
    local $self->{path} = [ @{ $self->{path} || [] }, $group_name ];
    local $self->{results} = $children;
    $group->[1] = $code->();
  }
  if ( not $self->{silent} and not $group->[1] ) {
    require Test::Builder;
    my $builder = Test::Builder->new();
    $builder->ok( $group->[1], "$group_name" );
    $builder->diag( $self->trace );
  }
  return $group->[1];
}

sub adopt {
  my ( $self, $group_name, $ok, @children ) = @_;
  if ( ref $children[0] ) {
    @children = @{ $children[0]->{results} || [] };
  }
  my $group = [ 'GROUP', $ok, $group_name, $self->{path}, \@children ];
  push @{ $self->{results} }, $group;
  if ( not $self->{silent} and not $ok ) {
    require Test::Builder;
    my $builder = Test::Builder->new();
    $builder->ok( $ok, "$group_name" );
    $builder->diag( $self->trace );
  }
  return $ok;
}

sub _format_result {
  my ($result) = @_;

  if ( 'NOTE' eq $result->[0] ) {
    return ( "# " . $result->[1] );
  }
  if ( 'OK' eq $result->[0] ) {

    return ( "- " . ( $result->[1] ? '[' . colored( ['green'], 'x' ) . ']' : colored( ['red'], '[ ]' ) ) . ' ' . $result->[2] );
  }
  if ( 'GROUP' eq $result->[0] ) {
    my @items;
    push @items,
      "* " . ( $result->[1] ? '[' . colored( ['green'], 'x' ) . ']' : colored( ['red'], '[ ]' ) ) . ' ' . $result->[2] . ' { ';
    push @items, map { "   $_" } map { _format_result($_) } @{ $result->[4] };
    push @items, '  } ';
    return @items;
  }
}

sub _pp_path {
  my ($path) = @_;
  $path ||= [];
  return join colored( ['magenta'], '/' ), @{$path};
}

sub trace {
  my ($self) = @_;
  return join qq[\n], map { _format_result($_) } @{ $self->{results} || [] };
}

1;

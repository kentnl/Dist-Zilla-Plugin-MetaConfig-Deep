use strict;
use warnings;

package T::HashRule;
use Path::Tiny qw(path);

use parent 'T::Chain';
use Exporter 5.57 qw( import );
our @EXPORT_OK = (qw( is_hash ));

sub is_hash {
  return __PACKAGE__->new();
}

sub init {
  $_[0]->_add_rule(
    'is_hash' => sub {
      my ($topic) = @_;
      my $topic_text = Test::Deep::render_val($topic);
      return ( 0, "Expected: HASH\nGot: $topic_text\n" )
        unless 'HASH' eq ref $topic;
      return ( 1, "Got expected HASH" );
    }
  );
}

sub has_key {
  my ( $self, $key, $rule ) = @_;
  my $key_text = Test::Deep::render_val($key);
  if ( not $rule ) {
    return $self->_add_rule(
      'has_key(' . $key_text . ')' => sub {
        my ($topic) = @_;
        return ( 0, "No Key $key_text" ) unless exists $topic->{$key};
        return ( 1, "Found key $key" );
      }
    );
  }
 return $self->_add_branch_rule(
      'has_key(' . $key_text . ', <rules>)' => sub {
        my ($topic) = @_;
        return ( 0, "No Key $key_text" ) unless exists $topic->{$key};
        return ( 1, "Found key $key" );
      }, sub { $_[0]->{$key} }, $rule );

}

1;

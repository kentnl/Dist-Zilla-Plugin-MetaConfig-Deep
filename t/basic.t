use strict;
use warnings;

use Test::More;

use Test::DZil qw( Builder simple_ini );
use Path::Tiny qw( path );
use Test::Deep;

# ABSTRACT: Ensure basic usage works

my $config = simple_ini( ['GatherDir'], ['MetaConfig::Deep'], );

use lib 't/lib';
use T::PathRule qw( is_path );
use T::HashRule qw( is_hash );

my $tzil = Builder->from_config(
  { dist_root => 'does-not-exist-' . $$ },
  {
    add_files => {
      path( 'source', 'dist.ini' ) => $config
    },
  },
);

cmp_deeply(
  $tzil,
  methods(
    'build' => is_path->dir->readable->has_child( 'dist.ini', is_path->file->readable ),
  ),
  'Basic Dist built ok',
);

use Test::Deep::Filter qw( filter );

my $rule = is_hash->has_key( 'x_Dist_Zilla', is_hash->has_key( 'plugins' ) );

cmp_deeply( $tzil->distmeta, $rule );

#cmp_deeply( {}  , is_hash->has_key( 'x_Dist_Zilla', is_hash->has_key('plugins') ), "Expected structure" );

done_testing;


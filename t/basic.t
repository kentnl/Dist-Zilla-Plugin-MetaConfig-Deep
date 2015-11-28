use strict;
use warnings;

use Test::More;

use Test::DZil qw( Builder simple_ini );
use Path::Tiny qw( path );

#use Test::Deep;

# ABSTRACT: Ensure basic usage works

my $config = simple_ini( ['GatherDir'], ['MetaConfig::Deep'], );

use lib 't/lib';

#use T::PathRule qw( is_path );
use T::HashRule qw( is_hash );
use T::ArrayRule qw( is_array );
use T::ScalarRule qw( is_scalar );

my $tzil = Builder->from_config(
  { dist_root => 'does-not-exist-' . $$ },
  {
    add_files => {
      path( 'source', 'dist.ini' ) => $config
    },
  },
);

$tzil->build;

#cmp_deeply(
#  $tzil,
#  methods(
#    'build' => is_path->dir->readable->has_child( 'dist.ini', is_path->file->readable ),
#  ),
#  'Basic Dist built ok',
#);

#use Test::Deep::Filter qw( filter );

is_hash('Metadata structure')
->has_key( 'x_Dist_Zilla' => 
    is_hash('x_Dist_Zilla structure')
    ->has_key( 'plugins' => 
        is_array('plugin data')
        ->has_entry(
          is_hash("An Entry Key")->has_key('class', is_scalar('The expected class')->equals('Dist::Zilla::Plugin::MetaConfig::Deep') )
        )
    )
)
->matches( $tzil->distmeta );

#cmp_deeply( $tzil->distmeta, $rule );

#cmp_deeply( {}  , is_hash->has_key( 'x_Dist_Zilla', is_hash->has_key('plugins') ), "Expected structure" );

done_testing;


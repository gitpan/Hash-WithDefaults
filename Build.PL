use strict;
use warnings;
use Module::Build;

my $builder = Module::Build->new(
    module_name         => 'Hash::WithDefaults',
    license             => 'perl',
    dist_author         => 'Jenda Krynicky <Jenda@Krynicky.cz>',
    dist_version_from   => 'lib/Hash/WithDefaults.pm',
	dist_abstract		=> 'class for hashes with key-casing requirements supporting defaults',
    build_requires => {
        'Test::More' => 0,
    },
    add_to_cleanup      => [ 'Hash-WithDefaults-*' ],
    create_makefile_pl => 'traditional',
);

$builder->create_build_script();

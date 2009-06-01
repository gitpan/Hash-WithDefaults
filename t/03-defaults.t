#!perl -T
use strict;
use Test::More tests => 1+30;
use Data::Dumper;

BEGIN {
	use_ok( 'Hash::WithDefaults' );
}

diag( "Testing Hash::WithDefaults $Hash::WithDefaults::VERSION, Perl $], $^X" );

{
	my %h;
	ok(
		tie( %h, 'Hash::WithDefaults', 'sensitive', low => 'value', Mix => 'other', HI => 'Some'),
		"Tied with case=sensitive"
	);

	my %def = (
		low => 'masked',
		def => 'default',
	);
	ok(
		tied(%h)->AddDefault( \%def ),
		"added some defaults"
	);

	is( ref(tied %h), 'Hash::WithDefaults::sensitive', "Tied to the right class");

	is( $h{low}, 'value', '$h{low}');
	is( $h{Low}, undef, '$h{Low}');
	is( $h{LOW}, undef, '$h{LOW}');

	is( $h{mix}, undef, '$h{mix}');
	is( $h{Mix}, 'other', '$h{Mix}');
	is( $h{MIX}, undef, '$h{MIX}');

	is( $h{hi}, undef, '$h{hi}');
	is( $h{Hi}, undef, '$h{Hi}');
	is( $h{HI}, 'Some', '$h{HI}');

	is( $h{def}, 'default', '$h{def}');
	is( $h{Def}, undef, '$h{Def}');
	is( $h{DEF}, undef, '$h{DEF}');

	my @got = sort keys %h;
	my @good = qw(HI Mix def low);

	is_deeply(\@got, \@good, "List of keys");

	@got = ();
	while (my ($key, $val) = each %h) {
		push @got, "$key=$val";
	}
	@got = sort @got;
	@good = ('HI=Some', 'Mix=other', 'def=default', 'low=value');
	is_deeply(\@got, \@good, "each() returns both keys and values");

	is( scalar( keys %h), 4, "Number of keys");

	delete $h{low};
	is( scalar( keys %h), 4, "Number of keys after delete \$h{low}");
	is( $h{low}, 'masked', '$h{low} eq "masked" after the delete');
	is( $h{Low}, undef, '$h{Low}');
	is( $h{LOW}, undef, '$h{LOW}');

	delete $h{Mix};
	is( scalar( keys %h), 3, "Number of keys after delete");
	is( $h{mix}, undef, '$h{mix}');
	is( $h{Mix}, undef, '$h{Mix}');
	is( $h{MIX}, undef, '$h{MIX}');

	%h = ();
	is( scalar( keys %h), 0, "Number of keys after clear");
	is_deeply( [keys %h], [], "There are no keys");

	$h{a} = 1; $h{B} = 2;
	is( scalar( keys %h), 2, "Number of keys after refil");
	is_deeply( [sort keys %h], [qw(B a)], "There are two keys");

}

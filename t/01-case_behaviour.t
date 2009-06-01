#!perl -T
use strict;
use Test::More tests => 1+6*26;
use Data::Dumper;

BEGIN {
	use_ok( 'Hash::WithDefaults' );
}

diag( "Testing Hash::WithDefaults $Hash::WithDefaults::VERSION, Perl $], $^X" );

{ # lower
	my %h;
	ok(
		tie( %h, 'Hash::WithDefaults', 'lower'),
		"Tied with case=lower"
	);

	is( ref(tied %h), 'Hash::WithDefaults::lower', "Tied to the right class");

	$h{low} = 'value';

	is( $h{low}, 'value', '$h{low}');
	is( $h{Low}, 'value', '$h{Low}');
	is( $h{LOW}, 'value', '$h{LOW}');

	$h{Mix} = 'other';

	is( $h{mix}, 'other', '$h{mix}');
	is( $h{Mix}, 'other', '$h{Mix}');
	is( $h{MIX}, 'other', '$h{MIX}');

	$h{HI} = 'Some';

	is( $h{hi}, 'Some', '$h{hi}');
	is( $h{Hi}, 'Some', '$h{Hi}');
	is( $h{HI}, 'Some', '$h{HI}');

	my @got = sort keys %h;
	my @good = qw(hi low mix);

	is_deeply(\@got, \@good, "List of keys");

	@got = ();
	while (my ($key, $val) = each %h) {
		push @got, "$key=$val";
	}
	@got = sort @got;
	@good = ('hi=Some', 'low=value', 'mix=other');
	is_deeply(\@got, \@good, "each() returns both keys and values");

	is( scalar( keys %h), 3, "Number of keys");

	delete $h{Low};
	is( scalar( keys %h), 2, "Number of keys after delete");
	is( $h{low}, undef, '$h{low}');
	is( $h{Low}, undef, '$h{Low}');
	is( $h{LOW}, undef, '$h{LOW}');

	delete $h{Mix};
	is( scalar( keys %h), 1, "Number of keys after delete");
	is( $h{mix}, undef, '$h{mix}');
	is( $h{Mix}, undef, '$h{Mix}');
	is( $h{MIX}, undef, '$h{MIX}');

	%h = ();
	is( scalar( keys %h), 0, "Number of keys after clear");
	is_deeply( [keys %h], [], "There are no keys");

	$h{a} = 1; $h{B} = 2;
	is( scalar( keys %h), 2, "Number of keys after refil");
	is_deeply( [sort keys %h], [qw(a b)], "There are two keys");

}

{ # upper
	my %h;
	ok(
		tie( %h, 'Hash::WithDefaults', 'upper'),
		"Tied with case=upper"
	);

	is( ref(tied %h), 'Hash::WithDefaults::upper', "Tied to the right class");

	$h{low} = 'value';

	is( $h{low}, 'value', '$h{low}');
	is( $h{Low}, 'value', '$h{Low}');
	is( $h{LOW}, 'value', '$h{LOW}');

	$h{Mix} = 'other';

	is( $h{mix}, 'other', '$h{mix}');
	is( $h{Mix}, 'other', '$h{Mix}');
	is( $h{MIX}, 'other', '$h{MIX}');

	$h{HI} = 'Some';

	is( $h{hi}, 'Some', '$h{hi}');
	is( $h{Hi}, 'Some', '$h{Hi}');
	is( $h{HI}, 'Some', '$h{HI}');

	my @got = sort keys %h;
	my @good = qw(HI LOW MIX);

	is_deeply(\@got, \@good, "List of keys");

	@got = ();
	while (my ($key, $val) = each %h) {
		push @got, "$key=$val";
	}
	@got = sort @got;
	@good = ('HI=Some', 'LOW=value', 'MIX=other');
	is_deeply(\@got, \@good, "each() returns both keys and values");

	is( scalar( keys %h), 3, "Number of keys");

	delete $h{Low};
	is( scalar( keys %h), 2, "Number of keys after delete");
	is( $h{low}, undef, '$h{low}');
	is( $h{Low}, undef, '$h{Low}');
	is( $h{LOW}, undef, '$h{LOW}');

	delete $h{Mix};
	is( scalar( keys %h), 1, "Number of keys after delete");
	is( $h{mix}, undef, '$h{mix}');
	is( $h{Mix}, undef, '$h{Mix}');
	is( $h{MIX}, undef, '$h{MIX}');

	%h = ();
	is( scalar( keys %h), 0, "Number of keys after clear");
	is_deeply( [keys %h], [], "There are no keys");

	$h{a} = 1; $h{B} = 2;
	is( scalar( keys %h), 2, "Number of keys after refil");
	is_deeply( [sort keys %h], [qw(A B)], "There are two keys");

}

{ # preserve
	my %h;
	ok(
		tie( %h, 'Hash::WithDefaults', 'preserve'),
		"Tied with case=preserve"
	);

	is( ref(tied %h), 'Hash::WithDefaults::preserve', "Tied to the right class");

	$h{low} = 'value';

	is( $h{low}, 'value', '$h{low}');
	is( $h{Low}, 'value', '$h{Low}');
	is( $h{LOW}, 'value', '$h{LOW}');

	$h{Mix} = 'other';

	is( $h{mix}, 'other', '$h{mix}');
	is( $h{Mix}, 'other', '$h{Mix}');
	is( $h{MIX}, 'other', '$h{MIX}');

	$h{HI} = 'Some';

	is( $h{hi}, 'Some', '$h{hi}');
	is( $h{Hi}, 'Some', '$h{Hi}');
	is( $h{HI}, 'Some', '$h{HI}');

	my @got = sort keys %h;
	my @good = qw(HI Mix low);

	is_deeply(\@got, \@good, "List of keys");

	@got = ();
	while (my ($key, $val) = each %h) {
		push @got, "$key=$val";
	}
	@got = sort @got;
	@good = ('HI=Some', 'Mix=other', 'low=value');
	is_deeply(\@got, \@good, "each() returns both keys and values");

	is( scalar( keys %h), 3, "Number of keys");

	delete $h{Low};
	is( scalar( keys %h), 2, "Number of keys after delete");
	is( $h{low}, undef, '$h{low}');
	is( $h{Low}, undef, '$h{Low}');
	is( $h{LOW}, undef, '$h{LOW}');

	delete $h{Mix};
	is( scalar( keys %h), 1, "Number of keys after delete");
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


{ # tolower
	my %h;
	ok(
		tie( %h, 'Hash::WithDefaults', 'tolower'),
		"Tied with case=tolower"
	);

	is( ref(tied %h), 'Hash::WithDefaults::tolower', "Tied to the right class");

	$h{low} = 'value';

	is( $h{low}, 'value', '$h{low}');
	is( $h{Low}, undef, '$h{Low}');
	is( $h{LOW}, undef, '$h{LOW}');

	$h{Mix} = 'other';

	is( $h{mix}, 'other', '$h{mix}');
	is( $h{Mix}, undef, '$h{Mix}');
	is( $h{MIX}, undef, '$h{MIX}');

	$h{HI} = 'Some';

	is( $h{hi}, 'Some', '$h{hi}');
	is( $h{Hi}, undef, '$h{Hi}');
	is( $h{HI}, undef, '$h{HI}');

	my @got = sort keys %h;
	my @good = qw(hi low mix);

	is_deeply(\@got, \@good, "List of keys");

	@got = ();
	while (my ($key, $val) = each %h) {
		push @got, "$key=$val";
	}
	@got = sort @got;
	@good = ('hi=Some', 'low=value', 'mix=other');
	is_deeply(\@got, \@good, "each() returns both keys and values");

	is( scalar( keys %h), 3, "Number of keys");

	delete $h{low};
	is( scalar( keys %h), 2, "Number of keys after delete");
	is( $h{low}, undef, '$h{low}');
	is( $h{Low}, undef, '$h{Low}');
	is( $h{LOW}, undef, '$h{LOW}');

	delete $h{Mix};
	is( scalar( keys %h), 2, "Number of keys after delete");
	is( $h{mix}, 'other', '$h{mix}');
	is( $h{Mix}, undef, '$h{Mix}');
	is( $h{MIX}, undef, '$h{MIX}');

	%h = ();
	is( scalar( keys %h), 0, "Number of keys after clear");
	is_deeply( [keys %h], [], "There are no keys");

	$h{a} = 1; $h{B} = 2;
	is( scalar( keys %h), 2, "Number of keys after refil");
	is_deeply( [sort keys %h], [qw(a b)], "There are two keys");

}

{ # toupper
	my %h;
	ok(
		tie( %h, 'Hash::WithDefaults', 'toupper'),
		"Tied with case=toupper"
	);

	is( ref(tied %h), 'Hash::WithDefaults::toupper', "Tied to the right class");

	$h{low} = 'value';

	is( $h{low}, undef, '$h{low}');
	is( $h{Low}, undef, '$h{Low}');
	is( $h{LOW}, 'value', '$h{LOW}');

	$h{Mix} = 'other';

	is( $h{mix}, undef, '$h{mix}');
	is( $h{Mix}, undef, '$h{Mix}');
	is( $h{MIX}, 'other', '$h{MIX}');

	$h{HI} = 'Some';

	is( $h{hi}, undef, '$h{hi}');
	is( $h{Hi}, undef, '$h{Hi}');
	is( $h{HI}, 'Some', '$h{HI}');

	my @got = sort keys %h;
	my @good = qw(HI LOW MIX);

	is_deeply(\@got, \@good, "List of keys");

	@got = ();
	while (my ($key, $val) = each %h) {
		push @got, "$key=$val";
	}
	@got = sort @got;
	@good = ('HI=Some', 'LOW=value', 'MIX=other');
	is_deeply(\@got, \@good, "each() returns both keys and values");

	is( scalar( keys %h), 3, "Number of keys");

	delete $h{LOW};
	is( scalar( keys %h), 2, "Number of keys after delete");
	is( $h{low}, undef, '$h{low}');
	is( $h{Low}, undef, '$h{Low}');
	is( $h{LOW}, undef, '$h{LOW}');

	delete $h{Mix};
	is( scalar( keys %h), 2, "Number of keys after delete");
	is( $h{mix}, undef, '$h{mix}');
	is( $h{Mix}, undef, '$h{Mix}');
	is( $h{MIX}, 'other', '$h{MIX}');

	%h = ();
	is( scalar( keys %h), 0, "Number of keys after clear");
	is_deeply( [keys %h], [], "There are no keys");

	$h{a} = 1; $h{B} = 2;
	is( scalar( keys %h), 2, "Number of keys after refil");
	is_deeply( [sort keys %h], [qw(A B)], "There are two keys");

}

{ # sensitive
	my %h;
	ok(
		tie( %h, 'Hash::WithDefaults', 'sensitive'),
		"Tied with case=sensitive"
	);

	is( ref(tied %h), 'Hash::WithDefaults::sensitive', "Tied to the right class");

	$h{low} = 'value';

	is( $h{low}, 'value', '$h{low}');
	is( $h{Low}, undef, '$h{Low}');
	is( $h{LOW}, undef, '$h{LOW}');

	$h{Mix} = 'other';

	is( $h{mix}, undef, '$h{mix}');
	is( $h{Mix}, 'other', '$h{Mix}');
	is( $h{MIX}, undef, '$h{MIX}');

	$h{HI} = 'Some';

	is( $h{hi}, undef, '$h{hi}');
	is( $h{Hi}, undef, '$h{Hi}');
	is( $h{HI}, 'Some', '$h{HI}');

	my @got = sort keys %h;
	my @good = qw(HI Mix low);

	is_deeply(\@got, \@good, "List of keys");

	@got = ();
	while (my ($key, $val) = each %h) {
		push @got, "$key=$val";
	}
	@got = sort @got;
	@good = ('HI=Some', 'Mix=other', 'low=value');
	is_deeply(\@got, \@good, "each() returns both keys and values");

	is( scalar( keys %h), 3, "Number of keys");

	delete $h{low};
	is( scalar( keys %h), 2, "Number of keys after delete");
	is( $h{low}, undef, '$h{low}');
	is( $h{Low}, undef, '$h{Low}');
	is( $h{LOW}, undef, '$h{LOW}');

	delete $h{MIX};
	is( scalar( keys %h), 2, "Number of keys after delete");
	is( $h{mix}, undef, '$h{mix}');
	is( $h{Mix}, 'other', '$h{Mix}');
	is( $h{MIX}, undef, '$h{MIX}');

	%h = ();
	is( scalar( keys %h), 0, "Number of keys after clear");
	is_deeply( [keys %h], [], "There are no keys");

	$h{a} = 1; $h{B} = 2;
	is( scalar( keys %h), 2, "Number of keys after refil");
	is_deeply( [sort keys %h], [qw(B a)], "There are two keys");

}

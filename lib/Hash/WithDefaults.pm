package Hash::WithDefaults;
use strict;
use Carp;
require Tie::Hash;
use vars qw(@ISA $VERSION);
@ISA = qw(Tie::StdHash);
$VERSION = '0.05';

sub _DATA () {0}
sub _DEFAULTS () {1}
sub _ACTDEFAULT () {2}
sub _SEEN () {3}

sub _makeTIEHASH {
	my ($class, $set) = @_;
	$class = 'Hash::WithDefaults::' . $class;
	eval "sub ${class}::TIEHASH {" . <<'*END*' . "\t\t\t" . $set . <<'*END*' . "\t\t\t" . $set . <<'*END*';
	my $class = shift();
	my $data = {};

	if (! @_) {
		# no parameters
		return bless [ $data, []], $class;
	}

	if (@_ == 1 and ref $_[0] eq 'HASH') {
		my $input=$_[0];
		my ($key,$value);
		while (($key,$value) = each(%$input)) {
*END*

		}
	} else {
		my ($i, $arr) = (0);
		if (ref $_[0] eq 'ARRAY') {
			$arr = $_[0];
		} elsif (@_ % 2 == 0) {
			$arr = \@_;
		} else {
			croak "Ussage: tie %hashname, $class, \%hash\n or tie %hashname, $class, \\\%hash\n or tie %hashname, $class, \\\@array\n";
		}
		while ($i <= $#$arr) {
			my ($key,$value)=($arr->[$i],$arr->[$i+1]); $i+=2;
*END*

		}
	}

	bless [$data, []], $class;
}
*END*
}

_makeTIEHASH 'sensitive', '$data->{$key} = $value;';
_makeTIEHASH 'tolower', '$data->{lc $key} = $value;';
_makeTIEHASH 'toupper', '$data->{uc $key} = $value;';
_makeTIEHASH 'lower', '$data->{lc $key} = $value;';
_makeTIEHASH 'upper', '$data->{uc $key} = $value;';
_makeTIEHASH 'preserve', '$data->{lc $key} = [$key,$value];';

sub TIEHASH {
	shift(); # shift out class name
	if (@_ == 0) {
		# no parameters
		unshift @_, 'Hash::WithDefaults::preserve';
		goto &Hash::WithDefaults::preserve::TIEHASH;
	}

	if (!ref $_[0] and (ref $_[1] eq 'HASH' or ref $_[1] eq 'ARRAY' or @_ % 2 == 1)) {
		# type plus either \%hash or %hash
		my $type = lc(splice(@_, 0, 1));
		if ($type =~ /^(?:sensitive|preserve|lower|upper|tolower|toupper)$/) {
			unshift @_, 'Hash::WithDefaults::' . $type;
			no strict 'refs';
			goto &{"Hash::WithDefaults::".$type."::TIEHASH"};
		} else {
			croak "Unknown type '$type'! Use one of:\n\tsensitive, preserve, lower, upper, tolower, toupper";
		}
	} else {
		unshift @_, 'Hash::WithDefaults::preserve';
		goto &Hash::WithDefaults::preserve::TIEHASH;
	}
}

sub AddDefault {
	push @{$_[0]->[_DEFAULTS]}, $_[1];
	return 1;
}

sub GetDefaults {
	my $self = shift;
	return $self->[_DEFAULTS];
}

sub CLEAR {
	my $self = shift;
	undef $self->[_DATA];
	@{$self->[_DEFAULTS]} = ();
	undef $self->[_SEEN];
	undef $self->[_ACTDEFAULT];
	$self
}


#############################

package Hash::WithDefaults::preserve;
BEGIN {*Hash::WithDefaults::Preserve:: = \%Hash::WithDefaults::preserve::;}
@Hash::WithDefaults::preserve::ISA = qw(Hash::WithDefaults);
sub _DATA () {0}
sub _DEFAULTS () {1}
sub _ACTDEFAULT () {2}
sub _SEEN () {3}


sub STORE {
    $_[0]->[_DATA]->{lc $_[1]} = [$_[1],$_[2]];
}

sub FETCH {
	my $lc_key = lc $_[1];
	return ${$_[0]->[_DATA]->{$lc_key}}[1]
		if exists $_[0]->[_DATA]->{$lc_key};

	foreach my $default (@{$_[0]->[_DEFAULTS]}) {
		return $default->{$_[1]}
			if exists($default->{$_[1]});
	}

	return;
}

sub EXISTS {
	return 1
		if exists $_[0]->[_DATA]->{lc $_[1]};

	foreach my $default (@{$_[0]->[_DEFAULTS]}) {
		return 1
			if exists($default->{$_[1]});
	}

	return;
}

sub DELETE {
	delete $_[0]->[_DATA]->{lc $_[1]}
}

sub FIRSTKEY {
	my $self = $_[0];
	undef $self->[_ACTDEFAULT];
	$self->[_SEEN] = {};
	keys %{$self->[_DATA]};
	my ($key,$val);
	if (($key,$val) = each %{$self->[_DATA]}) {
		$self->[_SEEN]->{$key}=1;
		return wantarray ? ($val->[0], $val->[1]) : $val->[0];
	} elsif (@{$self->[_DEFAULTS]}) {
		return $self->NEXTKEY();
	} else {
		return;
	}
}

sub NEXTKEY {
	my $self = $_[0];
	my $seen = $self->[_SEEN];
	my ($key,$val);
	if (!defined $self->[_ACTDEFAULT]) {
		# processing the base hash
		if (($key,$val) = each %{$self->[_DATA]}) {
			$seen->{$key}=1;
			return wantarray ? ($val->[0], $val->[1]) : $val->[0];
		} else {
			# base hash done
			if (! @{$self->[_DEFAULTS]}) {
				# no defaults
				return;
			} else {
				$self->[_ACTDEFAULT]=0;
				# reset the first default
				keys %{$self->[_DEFAULTS]->[0]};
			}
		}
	}

	while (exists $self->[_DEFAULTS]->[$self->[_ACTDEFAULT]]) {
		while (($key,$val) = each %{$self->[_DEFAULTS]->[$self->[_ACTDEFAULT]]}) {
			return wantarray ? ($key, $val) : $key
				unless $seen->{lc $key}++;
		}

		$self->[_ACTDEFAULT]++;
		keys %{$self->[_DEFAULTS]->[$self->[_ACTDEFAULT]]}
			if exists $self->[_DEFAULTS]->[$self->[_ACTDEFAULT]];
	}

	# all hashes done. Cleanup
	undef $self->[_SEEN];
	undef $self->[_ACTDEFAULT];
	return;
}

#############################

package Hash::WithDefaults::lower;
BEGIN {*Hash::WithDefaults::Lower:: = \%Hash::WithDefaults::lower::;}
@Hash::WithDefaults::lower::ISA = qw(Hash::WithDefaults::preserve);
sub _DATA () {0}
sub _DEFAULTS () {1}
sub _ACTDEFAULT () {2}
sub _SEEN () {3}

sub STORE {
    $_[0]->[_DATA]->{lc $_[1]} = $_[2];
}

sub FETCH {
	return $_[0]->[_DATA]->{lc $_[1]}
		if exists $_[0]->[_DATA]->{lc $_[1]};

	foreach my $default (@{$_[0]->[_DEFAULTS]}) {
		return $default->{$_[1]}
			if exists($default->{$_[1]});
	}

	return;
}

sub EXISTS {
	return 1
		if exists $_[0]->[_DATA]->{lc $_[1]};

	foreach my $default (@{$_[0]->[_DEFAULTS]}) {
		return 1
			if exists($default->{$_[1]});
	}

	return;
}

sub DELETE {
	delete $_[0]->[_DATA]->{lc $_[1]}
}

sub FIRSTKEY {
	my $self = $_[0];
	$self->[_ACTDEFAULT] = -1;
	$self->[_SEEN] = {};
	keys %{$self->[_DATA]};
	my ($key,$val);
	if (($key,$val) = each %{$self->[_DATA]}) {
		$self->[_SEEN]->{$key}=1;
		return wantarray ? ($key, $val) : $key;
	} elsif (@{$self->[_DEFAULTS]}) {
		return $self->NEXTKEY();
	} else {
		return;
	}
}

sub NEXTKEY {
	my $self = $_[0];
	my $seen = $self->[_SEEN];
	my $defaults = $self->[_DEFAULTS];
	my ($key,$val);
	if ($self->[_ACTDEFAULT] == -1) {
		# processing the base hash
		if (($key,$val) = each %{$self->[_DATA]}) {
			$seen->{$key}=1;
			return wantarray ? ($key, $val) : $key;
		} else {
			# base hash done
			$self->[_ACTDEFAULT]=0;
			if (! @$defaults) {
				# no defaults
				return;
			} else {
				# reset the first default
				keys %{$defaults->[0]};
			}
		}
	}
	while (exists $defaults->[$self->[_ACTDEFAULT]]) {
		while (($key,$val) = each %{$defaults->[$self->[_ACTDEFAULT]]}) {
			return wantarray ? ($key, $val) : $key
				unless $seen->{lc $key}++;
		}

		$self->[_ACTDEFAULT]++;
		keys %{$defaults->[$self->[_ACTDEFAULT]]}
			if exists $defaults->[$self->[_ACTDEFAULT]];
	}

	# all hashes done. Cleanup
	undef $self->[_SEEN];
	undef $self->[_ACTDEFAULT];
	return;
}

#############################

package Hash::WithDefaults::upper;
BEGIN {*Hash::WithDefaults::Upper:: = \%Hash::WithDefaults::upper::;}
@Hash::WithDefaults::upper::ISA = qw(Hash::WithDefaults::preserve);
sub _DATA () {0}
sub _DEFAULTS () {1}
sub _ACTDEFAULT () {2}
sub _SEEN () {3}

sub STORE {
    $_[0]->[_DATA]->{uc $_[1]} = $_[2];
}

sub FETCH {
	return $_[0]->[_DATA]->{uc $_[1]}
		if exists $_[0]->[_DATA]->{uc $_[1]};

	foreach my $default (@{$_[0]->[_DEFAULTS]}) {
		return $default->{$_[1]}
			if exists($default->{$_[1]});
	}

	return;
}

sub EXISTS {
	return 1
		if exists $_[0]->[_DATA]->{uc $_[1]};

	foreach my $default (@{$_[0]->[_DEFAULTS]}) {
		return 1
			if exists($default->{$_[1]});
	}

	return;
}

sub DELETE {
	delete $_[0]->[_DATA]->{uc $_[1]}
}

sub FIRSTKEY {
	my $self = $_[0];
	$self->[_ACTDEFAULT] = -1;
	$self->[_SEEN] = {};
	keys %{$self->[_DATA]};
	my ($key,$val);
	if (($key,$val) = each %{$self->[_DATA]}) {
		$self->[_SEEN]->{$key}=1;
		return wantarray ? ($key, $val) : $key;
	} elsif (@{$self->[_DEFAULTS]}) {
		return $self->NEXTKEY();
	} else {
		return;
	}
}

sub NEXTKEY {
	my $self = $_[0];
	my $seen = $self->[_SEEN];
	my $defaults = $self->[_DEFAULTS];
	my ($key,$val);
	if ($self->[_ACTDEFAULT] == -1) {
		# processing the base hash
		if (($key,$val) = each %{$self->[_DATA]}) {
			$seen->{$key}=1;
			return wantarray ? ($key, $val) : $key;
		} else {
			# base hash done
			$self->[_ACTDEFAULT]=0;
			if (! @$defaults) {
				# no defaults
				return;
			} else {
				# reset the first default
				keys %{$defaults->[0]};
			}
		}
	}
	while (exists $defaults->[$self->[_ACTDEFAULT]]) {
		while (($key,$val) = each %{$defaults->[$self->[_ACTDEFAULT]]}) {
			return wantarray ? ($key, $val) : $key
				unless $seen->{uc $key}++;
		}

		$self->[_ACTDEFAULT]++;
		keys %{$defaults->[$self->[_ACTDEFAULT]]}
			if exists $defaults->[$self->[_ACTDEFAULT]];
	}

	# all hashes done. Cleanup
	undef $self->[_SEEN];
	undef $self->[_ACTDEFAULT];
	return;
}


#############################

package Hash::WithDefaults::sensitive;
BEGIN {*Hash::WithDefaults::Sensitive:: = \%Hash::WithDefaults::sensitive::;}
@Hash::WithDefaults::sensitive::ISA = qw(Hash::WithDefaults);
sub _DATA () {0}
sub _DEFAULTS () {1}
sub _ACTDEFAULT () {2}
sub _SEEN () {3}

sub STORE {
    $_[0]->[_DATA]->{$_[1]} = $_[2];
}

sub FETCH {
	return $_[0]->[_DATA]->{$_[1]}
		if exists $_[0]->[_DATA]->{$_[1]};

	foreach my $default (@{$_[0]->[_DEFAULTS]}) {
		return $default->{$_[1]}
			if exists($default->{$_[1]});
	}

	return;
}

sub EXISTS {
	return 1
		if exists $_[0]->[_DATA]->{$_[1]};

	foreach my $default (@{$_[0]->[_DEFAULTS]}) {
		return 1
			if exists($default->{$_[1]});
	}

	return;
}

sub DELETE {
	delete $_[0]->[_DATA]->{$_[1]}
}

sub FIRSTKEY {
	my $self = $_[0];
	$self->[_ACTDEFAULT] = -1;
	$self->[_SEEN] = {};
	keys %{$self->[_DATA]};
	my ($key,$val);
	if (($key,$val) = each %{$self->[_DATA]}) {
		$self->[_SEEN]->{$key}=1;
		return wantarray ? ($key, $val) : $key;
	} elsif (@{$self->[_DEFAULTS]}) {
		return $self->NEXTKEY();
	} else {
		return;
	}
}

sub NEXTKEY {
	my $self = $_[0];
	my $seen = $self->[_SEEN];
	my $defaults = $self->[_DEFAULTS];
	my ($key,$val);
	if ($self->[_ACTDEFAULT] == -1) {
		# processing the base hash
		if (($key,$val) = each %{$self->[_DATA]}) {
			$seen->{$key}=1;
			return wantarray ? ($key, $val) : $key;
		} else {
			# base hash done
			$self->[_ACTDEFAULT]=0;
			if (! @$defaults) {
				# no defaults
				return;
			} else {
				# reset the first default
				keys %{$defaults->[0]};
			}
		}
	}
	while (exists $defaults->[$self->[_ACTDEFAULT]]) {
		while (($key,$val) = each %{$defaults->[$self->[_ACTDEFAULT]]}) {
			return wantarray ? ($key, $val) : $key
				unless $seen->{$key}++;
		}

		$self->[_ACTDEFAULT]++;
		keys %{$defaults->[$self->[_ACTDEFAULT]]}
			if exists $defaults->[$self->[_ACTDEFAULT]];
	}

	# all hashes done. Cleanup
	undef $self->[_SEEN];
	undef $self->[_ACTDEFAULT];
	return;
}


#############################

package Hash::WithDefaults::toupper;
BEGIN {*Hash::WithDefaults::Toupper:: = \%Hash::WithDefaults::toupper::;}
@Hash::WithDefaults::toupper::ISA = qw(Hash::WithDefaults::sensitive);
sub _DATA () {0}
sub _DEFAULTS () {1}
sub _ACTDEFAULT () {2}
sub _SEEN () {3}

sub STORE {
    $_[0]->[_DATA]->{uc $_[1]} = $_[2];
}

#############################

package Hash::WithDefaults::tolower;
BEGIN {*Hash::WithDefaults::Tolower:: = \%Hash::WithDefaults::tolower::;}
@Hash::WithDefaults::tolower::ISA = qw(Hash::WithDefaults::sensitive);
sub _DATA () {0}
sub _DEFAULTS () {1}
sub _ACTDEFAULT () {2}
sub _SEEN () {3}

sub STORE {
    $_[0]->[_DATA]->{lc $_[1]} = $_[2];
}

1;

__END__
=head1 NAME

Hash::WithDefaults

 - class for hashes with key-casing requirements supporting defaults

version 0.05

=head1 SYNOPSIS

  use Hash::WithDefaults;

  %main = ( ... );
  tie %h1, 'Hash::WithDefaults', {...};
  tied(%h1)->AddDefault(\%main);
  tie %h2, 'Hash::WithDefaults', [...];
  tied(%h2)->AddDefault(\%main);

  # now if you use $h1{$key}, the value is looked up first
  # in %h1, then in %main.

=head1 DESCRIPTION

This module implements hashes that support "defaults". That is you may specify
several more hashes in which the data will be looked up in case it is not found in
the current hash.

=head2 Object creation

	tie %hash, 'Hash::WithDefault', [$case_option], [\%values];
	tie %hash, 'Hash::WithDefault', [$case_option], [\@values];
	tie %hash, 'Hash::WithDefault', [$case_option], [%values];

The optional $case_option may be one of these values:

  Sensitive	- the hash will be case sensitive
  Tolower	- the hash will be case sensitive, all keys are made lowercase
  Toupper	- the hash will be case sensitive, all keys are made uppercase
  Preserve	- the hash will be case insensitive, the case is preserved
  Lower	- the hash will be case insensitive, all keys are made lowercase
  Upper	- the hash will be case insensitive, all keys are made uppercase

If you pass a hash or array reference or an even list of keys and values to the tie() function,
those keys and values will be COPIED to the resulting magical hash!

After you tie() the hash, you use it just like any other hash.

=head2 Functions

=head3 AddDefault

	tied(%hash)->AddDefault(\%defaults);

This instructs the object to include the %defaults in the search for values.
After this the value will be looked up first in %hash itself and then in %defaults.

You may keep modifying the %defaults and your changes WILL be visible through %hash!

You may add as many defaults to one Hash::WithDefaults object as you like, they will be searched
in the order you add them.

If you delete a key from the tied hash, it's only deleted from the list of specific keys, the defaults
are never modified through the tied hash. This means that you may get a default value for a key
after you deletethe key from the tied hash!

=head3 GetDefaults

	$defaults = tied(%hash)->GetDefaults();
	push @$defaults, \%another_default;

Returns a reference to the array that stores the defaults.
You may delete or insert hash references into the array, but make sure you
NEVER EVER insert anything else than a hash reference into the array!

=head2 Config::IniHash example

  use Config::IniHash;
  $config = ReadIni $inifile, withdefaults => 1, case => 'preserve';

  if (exists $config->{':default'}) {
    my $default = $config->{':default'};
    foreach my $section (keys %$config) {
      next if $section =~ /^:/;
	  tied(%{$config->{$section}})->AddDefault($default)
    }
  }

And now all normal sections will get the default values from [:default] section ;-)

=head1 AUTHOR

Jan Krynicky <Jenda@Krynicky.cz>
http://Jenda.Krynicky.cz

=head1 COPYRIGHT

Copyright (c) 2002-2009 Jan Krynicky <Jenda@Krynicky.cz>. All rights reserved.

This program is free software; you can redistribute it and/or
modify it under the same terms as Perl itself.

=cut

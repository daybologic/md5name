sub subtests_AnyInSet_Set() {
	my $rxSet = qr/^Invalid mandatory Set /;
	eval {
		AnyInSet();
	};
	like($@, $rxSet, 'AnyInSet ' . $rxSet);
	eval {
		AnyInSet(Set => undef);
	};
	like($@, $rxSet, 'AnyInSet ' . $rxSet);
	eval {
		AnyInSet(Set => 1);
	};
	like($@, $rxSet, 'AnyInSet ' . $rxSet);
	eval {
		AnyInSet(Set => []);
	};
	like($@, $rxSet, 'AnyInSet ' . $rxSet);
	eval {
		AnyInSet(Set => {});
	};
	is($@, '', 'AnyInSet');
}

sub subtests_AnyInSet_Excl() {
	my $ret;
	my $rxSet = qr/^Invalid optional Excl /;
	eval {
		AnyInSet(Set => {}, Excl => {});
	};
	like($@, $rxSet, 'AnyInSet ' . $rxSet);
	eval {
		AnyInSet(Set => {}, Excl => undef);
	};
	is($@, '', 'AnyInSet');
	eval {
		AnyInSet(Set => {}, Excl => []);
	};
	is($@, '', 'AnyInSet');
	eval {
		$ret = AnyInSet(
			Set => { horatio => 1, lenny => 1 },
			Excl => [ 'horatio' ]
		);
	};
	is($@, '', 'AnyInSet');
	is($ret, 'lenny', 'AnyInSet returned lenny');
}

my %subtests_Syntax_args = ( );
sub subtests_Syntax_setArgs(%) {
	%subtests_Syntax_args = @_;
}

sub subtests_Syntax_get($) {
	my $mode = shift;
	my %syntax = (
		'all' =>
			"dummy -S -? -n -h -q -x -s\n\n" .
			"\t-S\n" .
			"\t\tObfuscate filenames using a user-defined salt (MD5 or string)\n" .
			"\t-?/-h\n" .
			"\t\tDisplay help, use -? with another option for more detailed help\n" .
			"\t-n\n" .
			"\t\tNo-operation, Don\'t modify file-system\n" .
			"\t-q\n" .
			"\t\tQuiet, Do not output to stdout, only write errors on stderr\n" .
			"\t-x\n" .
			"\t\tRun regular expressions on filenames and skip matches\n" .
			"\t-s\n" .
			"\t\tDon\'t say we\'re renaming files where the result would be the same\n"

		, 'something else' => undef

	);
	return $syntax{$mode};
}

sub subtests_Syntax() {
	Syntax('dummy', undef, \%subtests_Syntax_args);
}

1;

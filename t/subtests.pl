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
		'bad' =>
			"dummy -S -? -n -h -q -x -s\n\n",

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
			"\t\tDon\'t say we\'re renaming files where the result would be the same\n",

		'S' =>
			"dummy -S -? -n -h -q -x -s\n\n" .
			"-S:\n" .
			"\tConsider a user-defined string (MD5'ed) or a direct MD5 string as part\n" .
			"\tof the MD5 calculation.  This ensures that people cannot use a search engine\n" .
			"\tto discover what the file is, if others hold a copy of the file.\n\n",

		'n' =>
			"dummy -S -? -n -h -q -x -s\n\n" .
			"-n:\n" .
			"\tWhen -n is specified, no operations are actually performed,\n" .
			"\tThe output is not changed, so it is not possible to tell the difference\n" .
			"\tbetween a real-run, and a no-op run.  Other flags are respected.\n\n",

		'q' =>
			"dummy -S -? -n -h -q -x -s\n\n" .
			"-q:\n" .
			"\tNo output will be produced on stdout.  This is useful when running from\n" .
			"\ta scheduled job.  Errors will still be produced on stderr.\n\n",

		'x' =>
			"dummy -S -? -n -h -q -x -s\n\n" .
			"-x:\n" .
			"\tAssume if a filename looks like an MD5 sum already, that it is,\n" .
			"\tthis will lead to massive optimisation when regularly re-processing\n" .
			"\ta large data set.  It is then recommended you very occasionally turn the\n" .
			"\tflag off to pick up files which have incorrect checksums.\n\n",

		's' =>
			"dummy -S -? -n -h -q -x -s\n\n" .
			"-s:\n" .
			"\tSkip over rename operations when the filename would be the same.\n" .
			"\tThis is a sensible default, but was not the default in version 1,\n" .
			"\tPlease use it unless you need the verbose output.\n\n",
	);
	my $ret = $syntax{$mode};
	BAIL_OUT('No syntax known for ' . $mode) unless ( $ret );
	return $ret;
}

sub subtests_Syntax() {
	Syntax('dummy', undef, \%subtests_Syntax_args);
}

1;

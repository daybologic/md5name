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

1;

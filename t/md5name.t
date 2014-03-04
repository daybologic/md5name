#!/usr/bin/perl -w

use strict;

require 'md5name.pl';
require 't/subtests.pl';

package main;
use Data::Dumper;
use Test::More tests => 23;
use Test::Output;

sub t_GetExt() {
	my %tData = (
		'blah.file' => [ 'blah', 'file'],
		'blah'      => [ '', undef ],
		'file.'     => [ '', 'file' ],
	);

	while ( my ( $file, $ext ) = each(%tData) ) {
		my @ret = GetExt($file);
		is_deeply(\@ret, $ext, sprintf('GetExt(\'%s\'): %s', $file, join(',', @$ext)));
	}
}

sub t_DisallowedExt() {
	my %tData = (
		'something' => 0,
		'htaccess'  => 1,
		'dirsz'     => 1,
		'txt'       => 1,
		'DS_Store'  => 1,
		''          => 0,
		'undef'     => 0
	);

	while ( my ( $ext, $expect ) = each(%tData) ) {
		is(DisallowedExt($ext), $expect, sprintf('DisallowedExt(\'%s\'): %u', $ext, $expect));
	}
	is(DisallowedExt(undef), 0, 'DisallowedExt(undef)');
}

sub t_AnyInSet() {

	subtests_AnyInSet_Set();
	subtests_AnyInSet_Excl();
}

sub t_Syntax() {
	subtests_Syntax_setArgs(h => 1);
	stdout_is(
		\&subtests_Syntax,
		subtests_Syntax_get('all'),
		'Syntax'
	);
	subtests_Syntax_setArgs(h => 1, S => 1);
	stdout_is(
		\&subtests_Syntax,
		subtests_Syntax_get('S'),
		'Syntax: S'
	);
}

sub t_main() {
	t_GetExt();
	t_DisallowedExt();
	t_AnyInSet();
	t_Syntax();
	return 0;
}

exit(t_main()); # Entry into test routines

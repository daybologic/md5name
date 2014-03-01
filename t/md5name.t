#!/usr/bin/perl -w

use strict;

require 'md5name.pl';

package main;
use Test::More tests => 3;

sub t_GetExt() {
	my %tData = (
		'blah.file' => 'file',
		'blah'      => undef,
		'file.'     => ''
	);

	while ( my ( $file, $ext ) = each(%tData) ) {
		is(GetExt($file), $ext, sprintf('GetExt(\'%s\'): %s', $file, $ext));
	}
}

sub t_main() {
	t_GetExt();
}

exit(t_main()); # Entry into test routines

#!/usr/bin/perl -w

use strict;

require 'md5name.pl';

package main;
use Data::Dumper;
use Test::More tests => 3;

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

sub t_main() {
	t_GetExt();
}

exit(t_main()); # Entry into test routines

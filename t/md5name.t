#!/usr/bin/perl -w

use strict;

require 'md5name.pl';

package main;
use Test::More tests => 1;

sub t_main() {
	GetExt();
}

exit(t_main()); # Entry into test routines

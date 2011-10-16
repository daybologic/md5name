#!/usr/bin/perl -w
#
# MD5Name iterates through a directory and renames all files
# in it to their MD5 sums.
#

use Digest::MD5;
use Getopt::Std;

use strict;
use warnings;
use diagnostics;

use constant ARG_LIST => '?hnqsx';

my %Opts = ( );

sub DisallowedExt($);
sub GetExt($);
sub Program($);

sub Program($)
{
	my $filename;
	my $dirname = $_[0];
	local *dirHandle;
	if ( opendir(dirHandle, $dirname) ) {
		while ( $filename = readdir(dirHandle) ) {
			if ( ($filename eq '.') or ($filename eq '..') ) { next; }
			if ( -d ( $dirname . '/' . $filename ) ) {
				print "Recalling Program($dirname/$filename)\n";
				Program($dirname . '/' . $filename);
			} else {
				if ( open(my $fileHandle, '<' . $dirname . '/' . $filename) ) {
					my $ctx = Digest::MD5->new;
					my $digest;
					my $ext;

					$ext = GetExt($filename);
					$ctx->addfile($fileHandle);
					close($fileHandle);
					$digest = $ctx->hexdigest;

					if ( !DisallowedExt($ext) ) {
						$digest = $digest . '.' . $ext if ( $ext );
						print "Rename $dirname/$filename to $dirname/$digest\n";
						rename $dirname . '/' . $filename, $dirname . '/' . $digest;
					}
				}
			}
		}
		closedir(dirHandle);
	}
	return;
}

sub GetExt($)
{
	my $fn = $_[0];
	my @arr;
	my $ext;

	@arr = split(m/\./, $fn);
	$ext = $arr[scalar(@arr)-1];
	if ( $fn eq $ext ) { return undef; }
	return $ext;
}

sub DisallowedExt($)
{
	my %disallowed = map { $_ => 1 } ( 'htaccess', 'dirsz', 'txt', 'DS_Store' );
	my $ext = $_[0];
	return 1 if ( $ext && $disallowed{$ext} );
	return 0;
}

sub AnyInSet(@)
{
	my $ret = undef;
	my %Params = ( );
	my ( $Set, $Excl );
	%Params = @_ if ( @_ );
	$Set = $Params{'Set'};
	$Excl = $Params{'Excl'};
	die 'Invalid mandatory Set' unless ( $Set && ref($Set) && ref($Set) eq 'HASH' );
	if ( $Excl ) {
		die 'Invalid optional Excl' unless ( ref($Excl) && ref($Excl) eq 'ARRAY' );
	}

	foreach my $member ( keys(%$Set) ) {
		if ( $Excl ) {
			my $outerNext = 0;
			foreach my $x ( @$Excl ) {
				if ( $member eq $x ) {
					$outerNext++;
					last;
				}
			}
			next if ( $outerNext );
		}
		if ( $Set->{$member} ) {
			$ret = $member;
			last;
		}
	}
	return $ret;
}

sub Syntax($$$)
{
	my $xHelp;
	my ( $AppName, $ArgList, $Args ) = @_;
	my %overview = (
		'?' => 'Display help, use -? with another option for more detailed help',
		'h' => undef,
		'n' => 'No-operation, Don\'t modify file-system',
		'q' => 'Quiet, Do not output to stdout, only write errors on stderr',
		's' => 'Don\'t say we\'re renaming files where the result would be the same',
		'x' => 'Run regular expressions on filenames and skip matches'
	);
	my %detail = (
		'n' => "\tWhen -n is specified, no operations are actually performed,\n" .
		       "\tThe output is not changed, so it is not possible to tell the difference\n" .
		       "\tbetween a real-run, and a no-op run.  Other flags are respected.\n",

		'q' => "\tNo output will be produced on stdout.  This is useful when running from\n" .
		       "\ta scheduled job.  Errors will still be produced on stderr.\n",

		's' => "\tSkip over rename operations when the filename would be the same.\n" .
		       "\tThis is a sensible default, but was not the default in version 1,\n" .
		       "\tPlease use it unless you need the verbose output.\n",

		'x' => "\tAssume if a filename looks like an MD5 sum already, that it is,\n" .
		       "\tthis will lead to massive optimisation when regularly re-processing\n" .
		       "\ta large data set.  It is then recommended you very occasionally turn the\n" .
		       "\tflag off to pick up files which have incorrect checksums.\n"
	);
	$overview{'h'} = $overview{'?'}; # Fixup for -h to be the same as -?

	printf("%s -%s\n", $AppName, join(' -', keys(%overview)));
	$xHelp = AnyInSet(Set => $Args, Excl => [ 'h', '?' ]);
	print("\n");
	if ( $xHelp ) {
		printf("-%s:\n%s\n", $xHelp, $detail{$xHelp});
	} else {
		foreach my $o ( keys(%overview) ) {
			printf("\t-%s\n\t\t%s\n", $o, $overview{$o});
		}
	}
}

# Program entry point
getopts(ARG_LIST(), \%Opts);
if ( $Opts{'?'} || $Opts{'h'} ) {
	Syntax($0, ARG_LIST(), \%Opts);
} else {
	Program($ARGV[0]);
}
exit(0);

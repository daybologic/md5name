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

use constant ARG_LIST => 'hnqsxS:';

my %Opts = ( );
my $RegexMD5 = qr/^[0-9a-f]{32}$/; # Matches MD5 sums
my $UserSalt = '';

sub DisallowedExt($);
sub GetExt($);
sub Program($);

sub Program($) {
	my $filename;
	my $dirname = $_[0];
	local *dirHandle;
	if ( opendir(dirHandle, $dirname) ) {
		while ( $filename = readdir(dirHandle) ) {
			if ( ($filename eq '.') or ($filename eq '..') ) { next; }
			if ( -d ( $dirname . '/' . $filename ) ) {
				print "Recalling Program($dirname/$filename)\n" unless ( $Opts{'q'} );
				Program($dirname . '/' . $filename);
			} else {
				my $digest = undef; # The real digest via the MD5 algorithm
				my ( $fnMain, $ext ) = GetExt($filename);

				if ( $Opts{'x'} ) { # Use regexes to avoid MD5?
					$digest = $fnMain if ( $fnMain =~ $RegexMD5 );
				}
				if ( !$digest && open(my $fileHandle, '<', $dirname . '/' . $filename) ) {
					my $ctx = Digest::MD5->new;

					$ctx->addfile($fileHandle);
					close($fileHandle);
					$ctx->add($UserSalt) if ( $UserSalt );
					$digest = $ctx->hexdigest;
				}

				if ( !DisallowedExt($ext) ) {
					my ( $a, $b );
					$digest = $digest . '.' . $ext if ( $ext );
					$a = "$dirname/$filename";
					$b = "$dirname/$digest";
					unless ( $Opts{'q'} ) {
						my $doPrint = 1;
						$doPrint = 0 if ( $Opts{'s'} && $a eq $b );
						print "Rename $a to $b\n" if ( $doPrint );
					}
					rename($a, $b)
						if ( !$Opts{'n'} && $filename ne $digest );
				}
			}
		}
		closedir(dirHandle);
	}
	return;
}

sub GetExt($) {
	my $fn = $_[0];
	my @arr;
	my ( $fnMain, $ext );

	return undef if ( !defined($fn) );
	@arr = split(m/\./, $fn);
	$ext = pop(@arr);
	$fnMain = join('.', @arr);
	$ext = undef if ( $fn eq $ext ); # Filename has no extension
	return ( $fnMain, $ext );
}

sub DisallowedExt($) {
	my %disallowed = map { $_ => 1 } ( 'htaccess', 'dirsz', 'txt', 'DS_Store' );
	my $ext = $_[0];
	return 1 if ( $ext && $disallowed{$ext} );
	return 0;
}

sub AnyInSet(@) {
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
		if ( exists($Set->{$member}) ) {
			$ret = $member;
			last;
		}
	}
	return $ret;
}

sub Syntax($$$) {
	my $xHelp;
	my ( $AppName, $ArgList, $Args ) = @_;
	my %overview = (
		'?' => 'Display help, use -? with another option for more detailed help',
		'h' => undef,
		'n' => 'No-operation, Don\'t modify file-system',
		'q' => 'Quiet, Do not output to stdout, only write errors on stderr',
		's' => 'Don\'t say we\'re renaming files where the result would be the same',
		'x' => 'Run regular expressions on filenames and skip matches',
		'S' => 'Obfuscate filenames using a user-defined salt (MD5 or string)'
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
		       "\tflag off to pick up files which have incorrect checksums.\n",

		'S' => "\tConsider a user-defined string (MD5'ed) or a direct MD5 string as part\n" .
		       "\tof the MD5 calculation.  This ensures that people cannot use a search engine\n" .
		       "\tto discover what the file is, if others hold a copy of the file.\n"
	);
	$overview{'h'} = $overview{'?'}; # Fixup for -h to be the same as -?

	printf("%s -%s\n", $AppName, join(' -', keys(%overview)));
	$xHelp = AnyInSet(Set => $Args, Excl => [ 'h', '?' ]);
	print("\n");
	if ( $xHelp ) {
		printf("-%s:\n%s\n", $xHelp, $detail{$xHelp}) if ( $detail{$xHelp} );
	} else {
		foreach my $o ( keys(%overview) ) {
			my $visOpt = '-'.$o;
			if ( $o eq 'h' ) { next; } elsif ( $o eq '?' ) { $visOpt = '-?/-h'; }
			printf("\t%s\n\t\t%s\n", $visOpt, $overview{$o});
		}
	}
}

sub getoptswrapper($$@) {
	my ( $ret, $active ) = ( 0, 1 );
	my @remaining = ( );
	my ( $Args, $Opts, @Unit_OR ) = @_;

	# Do pre-rocessing to handle -?, which getopts() can't handle.
	@ARGV = @Unit_OR if ( scalar(@Unit_OR) );
	foreach my $o ( @ARGV ) {
		$active = 0 if ( $active && $o eq '--' );
		if ( $active && $o eq '-?' ) {
			$Opts->{'?'} = 1;
		} else {
			push(@remaining, $o);
		}
	}
	@ARGV = @remaining if ( scalar(@remaining) < scalar(@ARGV) );
	$ret = getopts($Args, $Opts); # Call the usual getopts() function
	return $ret;
}

sub main() {
	getoptswrapper(ARG_LIST(), \%Opts, undef);
	if ( $Opts{'?'} || $Opts{'h'} ) {
		Syntax($0, ARG_LIST(), \%Opts);
		return 1;
	} else {
		if ( $Opts{'S'} ) { # User-supplied salt?
			if ( $Opts{'S'} =~ $RegexMD5 ) { # It's a direct MD5 sum
				$UserSalt = $Opts{'S'};
			} else {
				my $user_salt_ctx = Digest::MD5->new;
				$user_salt_ctx->add($Opts{'S'});
				$UserSalt = $user_salt_ctx->hexdigest();
			}
		}
		if ( $ARGV[0] ) {
			Program($ARGV[0]);
			return 0;
		}
		printf(STDERR "%s: ERROR processing command-line arguments.\n", $0);
		return 1;
	}
}

exit(main()) unless (caller()); # Program entry point
1;

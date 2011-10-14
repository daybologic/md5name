#!/usr/bin/perl -w
#
# MD5Name iterates through a directory and renames all files
# in it to their MD5 sums.
#

use Digest::MD5;

sub DisallowedExt($);
sub GetExt($);
sub Program($);

# Program entry point
Program($ARGV[0]);
exit 0;

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
				if ( open(FILEHANDLE, '<' . $dirname . '/' . $filename) ) {
					my $ctx = Digest::MD5->new;
					my $digest;
					my $ext;

					$ext = GetExt($filename);
					$ctx->addfile(FILEHANDLE);
					close(FILEHANDLE);
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
	my $ext = $_[0];
	if ( $ext ) {
		if ( $ext eq 'htaccess' ) { return 1; }
		if ( $ext eq 'dirsz' ) { return 1; }
		if ( $ext eq 'txt' ) { return 1; }
		if ( $ext eq 'DS_Store' ) { return 1; }
	}
	return 0;
}

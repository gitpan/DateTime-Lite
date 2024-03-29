package DateTime::Lite::TimeZone::Local::Unix;

use strict;
use warnings;

use base 'DateTime::Lite::TimeZone::Local';


sub Methods
{
    return qw( FromEnv
               FromEtcLocaltime
               FromEtcTimezone
               FromEtcTIMEZONE
               FromEtcSysconfigClock
               FromEtcDefaultInit
             );
}

sub EnvVars { return 'TZ' }

sub FromEtcLocaltime
{
    my $class = shift;

    my $lt_file = '/etc/localtime';

    return unless -r $lt_file && -s _;

    my $real_name;
    if ( -l $lt_file )
    {
	# The _Readlink sub exists so the test suite can mock it.
	$real_name = $class->_Readlink( $lt_file );
    }

    $real_name ||= $class->_FindMatchingZoneinfoFile( $lt_file );

    if ( defined $real_name )
    {
	my ( $vol, $dirs, $file ) = File::Spec->splitpath( $real_name );

	my @parts =
	    grep { defined && length } File::Spec->splitdir( $dirs ), $file;

        foreach my $x ( reverse 0..$#parts )
        {
            my $name =
                ( $x < $#parts ?
                  join '/', @parts[$x..$#parts] :
                  $parts[$x]
                );

            my $tz;
            {
                local $@;
                $tz = eval { DateTime::Lite::TimeZone->load( name => $name ) };
            }

            return $tz if $tz;
        }
    }
}

sub _Readlink
{
    my $link = $_[1];

    require Cwd;
    # Using abs_path will resolve multiple levels of link indirection,
    # whereas readlink just follows the link to the next target.
    return Cwd::abs_path($link);
}

# for systems where /etc/localtime is a copy of a zoneinfo file
sub _FindMatchingZoneinfoFile
{
    my $class         = shift;
    my $file_to_match = shift;

    return unless -d '/usr/share/zoneinfo';

    require File::Basename;
    require File::Compare;
    require File::Find;

    my $size = -s $file_to_match;

    my $real_name;
    local $@;
    local $_;
    eval
    {
        local $SIG{__DIE__};
        File::Find::find
            ( { wanted =>
                sub
                {
                    if ( ! defined $real_name
                         && -f $_
                         && ! -l $_
                         && $size == -s _
                         # This fixes RT 24026 - apparently such a
                         # file exists on FreeBSD and it can cause a
                         # false positive
                         && File::Basename::basename($_) ne 'posixrules'
                         && File::Compare::compare( $_, $file_to_match ) == 0
                       )
                    {
                        $real_name = $_;

                        # File::Find has no mechanism for bailing in the
                        # middle of a find.
                        die { found => 1 };
                    }
                },
                no_chdir => 1,
              },
              '/usr/share/zoneinfo',
            );
    };

    if ($@)
    {
        return $real_name if ref $@ && $@->{found};
        die $@;
    }
}

sub FromEtcTimezone
{
    my $class = shift;

    my $tz_file = '/etc/timezone';

    return unless -f $tz_file && -r _;

    local *TZ;
    open TZ, "<$tz_file"
        or die "Cannot read $tz_file: $!";
    my $name = join '', <TZ>;
    close TZ;

    $name =~ s/^\s+|\s+$//g;

    return unless $class->_IsValidName($name);

    local $@;
    return eval { DateTime::Lite::TimeZone->load( name => $name ) };
}

sub FromEtcTIMEZONE
{
    my $class = shift;

    my $tz_file = '/etc/TIMEZONE';

    return unless -f $tz_file && -r _;

    local *TZ;
    open TZ, "<$tz_file"
        or die "Cannot read $tz_file: $!";

    my $name;
    while ( defined( $name = <TZ> ) )
    {
        if ( $name =~ /\A\s*TZ\s*=\s*(\S+)/ )
        {
            $name = $1;
            last;
        }
    }

    close TZ;

    return unless $class->_IsValidName($name);

    local $@;
    return eval { DateTime::Lite::TimeZone->load( name => $name ) };
}

# RedHat uses this
sub FromEtcSysconfigClock
{
    my $class = shift;

    return unless -r "/etc/sysconfig/clock" && -f _;

    my $name = $class->_ReadEtcSysconfigClock();

    return unless $class->_IsValidName($name);

    local $@;
    return eval { DateTime::Lite::TimeZone->load( name => $name ) };
}

# this is a sparate function so that it can be overridden in the test
# suite
sub _ReadEtcSysconfigClock
{
    my $class = shift;

    local *CLOCK;
    open CLOCK, '</etc/sysconfig/clock'
        or die "Cannot read /etc/sysconfig/clock: $!";

    local $_;
    while (<CLOCK>)
    {
        return $1 if /^(?:TIME)?ZONE="([^"]+)"/;
    }
}

sub FromEtcDefaultInit
{
    my $class = shift;

    return unless -r "/etc/default/init" && -f _;

    my $name = $class->_ReadEtcDefaultInit();

    return unless $class->_IsValidName($name);

    local $@;
    return eval { DateTime::Lite::TimeZone->load( name => $name ) };
}

# this is a separate function so that it can be overridden in the test
# suite
sub _ReadEtcDefaultInit
{
    my $class = shift;

    local *INIT;
    open INIT, '</etc/default/init'
        or die "Cannot read /etc/default/init: $!";

    local $_;
    while (<INIT>)
    {
        return $1 if /^TZ=(.+)/;
    }
}


1;

__END__

=head1 NAME

DateTime::Lite::TimeZone::Local::Unix - Determine the local system's time zone on Unix

=head1 SYNOPSIS

  my $tz = DateTime::Lite::TimeZone->new( name => 'local' );

  my $tz = DateTime::Lite::TimeZone::Local->TimeZone();

=head1 DESCRIPTION

This module provides methods for determining the local time zone on a
Unix platform.

=head1 HOW THE TIME ZONE IS DETERMINED

This class tries the following methods of determining the local time
zone:

=over 4

=item * $ENV{TZ}

It checks C<< $ENV{TZ} >> for a valid time zone name.

=item * F</etc/localtime>

If this file is a symlink to an Olson database time zone file (usually
in F</usr/share/zoneinfo>) then it uses the target file's path name to
determine the time zone name. For example, if the path is
F</usr/share/zoneinfo/America/Chicago>, the time zone is
"America/Chicago".

Some systems just copy the relevant file to F</etc/localtime> instead
of making a symlink.  In this case, we look in F</usr/share/zoneinfo>
for a file that has the same size and content as F</etc/localtime> to
determine the local time zone.

=item * F</etc/timezone>

If this file exists, it is read and its contents are used as a time
zone name.

=item * F</etc/TIMEZONE>

If this file exists, it is opened and we look for a line starting like
"TZ = ...". If this is found, it should indicate a time zone name.

=item * F</etc/sysconfig/clock>

If this file exists, it is opened and we look for a line starting like
"TIMEZONE = ..." or "ZONE = ...". If this is found, it should indicate
a time zone name.

=item * F</etc/default/init>

If this file exists, it is opened and we look for a line starting like
"TZ=...". If this is found, it should indicate a time zone name.

=back

=head1 AUTHOR

Dave Rolsky, <autarch@urth.org>

=head1 COPYRIGHT & LICENSE

Copyright (c) 2003-2008 David Rolsky.  All rights reserved.  This
program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

The full text of the license can be found in the LICENSE file included
with this module.

=cut

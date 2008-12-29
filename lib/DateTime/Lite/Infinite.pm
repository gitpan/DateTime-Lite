# $Id: /mirror/coderepos/lang/perl/DateTime-Lite/trunk/lib/DateTime/Lite/Infinite.pm 92502 2008-11-24T14:19:18.555473Z daisuke  $

package DateTime::Lite::Infinite;
use strict;
use base qw(DateTime::Lite);
use DateTime::Lite::TimeZone;

sub set           { $_[0] }
sub set_time_zone { $_[0] }
sub truncate      { $_[0] }
sub is_finite     { 0 }
sub is_infinite   { 1 }

sub _calc_local_components {
    my $self = shift;

    my @list = qw(
        year month day day_of_week day_of_year quarter day_of_quarter
        hour minute second 
    );
    @{ $self->{local_c} }{ @list } = (
        ( $self->{local_rd_days} ) x 7,
        ( $self->{local_rd_secs} ) x 3,
    );
}

sub _stringify_overload {
    return $_[0]->{utc_rd_days} == &DateTime::Lite::INFINITY ?
        (&DateTime::Lite::INFINITY . '') :
        (&DateTime::Lite::NEG_INFINITY . '')
}

sub STORABLE_freeze { return }
sub STORABLE_thaw { return }

package #
    DateTime::Lite::Infinite::Future;
use strict;
use base qw(DateTime::Lite::Infinite);

{
    my $Pos;

    sub new {
        return $Pos if $Pos;

        my $class = shift;
        $Pos = bless {
            utc_rd_days   => &DateTime::Lite::INFINITY,
            utc_rd_secs   => &DateTime::Lite::INFINITY,
            local_rd_days => &DateTime::Lite::INFINITY,
            local_rd_secs => &DateTime::Lite::INFINITY,
            rd_nanosecs   => &DateTime::Lite::INFINITY,
            tz            => DateTime::Lite::TimeZone->load( name => 'floating' ),
        }, $class;

        $Pos->_calc_utc_rd;
        $Pos->_calc_local_rd;
        return $Pos;
    }
}

package #
    DateTime::Lite::Infinite::Past;
use strict;
use base qw(DateTime::Lite::Infinite);

{
    my $Neg;
    sub new {
        return $Neg if $Neg;

        my $class = shift;
        $Neg = bless {
            utc_rd_days   => &DateTime::Lite::NEG_INFINITY,
            utc_rd_secs   => &DateTime::Lite::NEG_INFINITY,
            local_rd_days => &DateTime::Lite::NEG_INFINITY,
            local_rd_secs => &DateTime::Lite::NEG_INFINITY,
            rd_nanosecs   => &DateTime::Lite::NEG_INFINITY,
            tz            => DateTime::Lite::TimeZone->load( name => 'floating' ),
        }, $class;

        $Neg->_calc_utc_rd;
        $Neg->_calc_local_rd;
        return $Neg;
    }
}

1;

__END__

=head1 NAME

DateTime::Lite::Infinite - Infinite past and future DateTime::Lite objects

=head1 SYNOPSIS

  my $future = DateTime::Lite::Infinite::Future->new;
  my $past   = DateTime::Lite::Infinite::Past->new;

=head1 DESCRIPTION

This module provides two L<DateTime::Lite.pm|DateTime::Lite> subclasses,
C<DateTime::Lite::Infinite::Future> and C<DateTime::Lite::Infinite::Past>.

The objects are in the "floating" timezone, and this cannot be
changed.

=head1 BUGS

There seem to be lots of problems when dealing with infinite numbers
on Win32.  This may be a problem with this code, Perl, or Win32's IEEE
math implementation.  Either way, the module may not be well-behaved
on Win32 operating systems.

=head1 METHODS

The only constructor for these two classes is the C<new()> method, as
shown in the L<SYNOPSIS|/SYNOPSIS>.  This method takes no parameters.

All "get" methods in this module simply return infinity, positive or
negative.  If the method is expected to return a string, it return the
string representation of positive or negative infinity used by your
system.  For example, on my system calling C<year()> returns a number
which when printed appears either "inf" or "-inf".

The object is not mutable, so the C<set()>, C<set_time_zone()>, and
C<truncate()> methods are all do-nothing methods that simply return
the object they are called with.

Obviously, the C<is_finite()> method returns false and the
C<is_infinite()> method returns true.

=head1 AUTHOR

Dave Rolsky <autarch@urth.org>

=head1 COPYRIGHT

Copyright (c) 2003-2006 David Rolsky.  All rights reserved.  This
program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

The full text of the license can be found in the LICENSE file included
with this module.

=head1 SEE ALSO

datetime@perl.org mailing list

http://datetime.perl.org/

=cut

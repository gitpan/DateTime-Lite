# $Id: /mirror/coderepos/lang/perl/DateTime-Lite/trunk/lib/DateTime/Lite/TimeZone/Floating.pm 91810 2008-11-18T10:56:02.250608Z daisuke  $

package DateTime::Lite::TimeZone::Floating;
use strict;
use base qw(DateTime::Lite::TimeZone::OffsetOnly);

sub new {
    my $class = shift;
    bless {name => 'floating', offset => 0}, $class;
}

sub is_floating { 1 };

1;
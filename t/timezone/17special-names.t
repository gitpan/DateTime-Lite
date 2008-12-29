use strict;
use warnings;

use File::Spec;
use Test::More;

use DateTime::Lite::TimeZone


plan tests => 11;

for my $name ( qw( EST MST HST CET EET MET WET EST5EDT CST6CDT MST7MDT PST8PDT ) )
{
    my $tz = eval { DateTime::Lite::TimeZone->load( name => $name ) };
    ok( $tz, "got a timezone for name => $name" . ($@ ? ": $@" : '') );
}

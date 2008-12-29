use strict;
use warnings;

use File::Spec;
use Test::More;

use lib File::Spec->catdir( File::Spec->curdir, 't' );


use DateTime::Lite::TimeZone;

my @links = DateTime::Lite::TimeZone::links();

plan tests => @links + 2;

for my $link (@links)
{
    my $tz = DateTime::Lite::TimeZone->load( name => $link );
    isa_ok( $tz, 'DateTime::Lite::TimeZone' );
}

my $tz = DateTime::Lite::TimeZone->load( name => 'Libya' );
is( $tz->name, 'Africa/Tripoli', 'check ->name' );

$tz = DateTime::Lite::TimeZone->load( name => 'US/Central' );
is( $tz->name, 'America/Chicago', 'check ->name' );

use strict;
use warnings;

use File::Spec;
use Test::More;
use DateTime::Lite::TimeZone;

use lib File::Spec->catdir( File::Spec->curdir, 't' );


plan tests => 1;

{
    my $tz = eval { DateTime::Lite::TimeZone->load( name => 'America/Chicago; print "hello, world\n";' ) };
    like( $@, qr/invalid name/, 'make sure potentially malicious code cannot sneak into eval' );
}

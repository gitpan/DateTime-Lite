#!/usr/bin/perl -w

use strict;

use Test::More tests => 8;

use DateTime::Lite;
use DateTime::Lite::Locale;

eval { DateTime::Lite->new( year => 100, locale => 'en_US' ) };
is( $@, '', 'make sure constructor accepts locale parameter' );

eval { DateTime::Lite->now( locale => 'en_US' ) };
is( $@, '', 'make sure constructor accepts locale parameter' );

eval { DateTime::Lite->today( locale => 'en_US' ) };
is( $@, '', 'make sure constructor accepts locale parameter' );

eval { DateTime::Lite->from_epoch( epoch => 1, locale => 'en_US' ) };
is( $@, '', 'make sure constructor accepts locale parameter' );

eval { DateTime::Lite->last_day_of_month( year => 100, month => 2, locale => 'en_US' ) };
is( $@, '', 'make sure constructor accepts locale parameter' );

{
    package DT::Object;
    sub utc_rd_values { ( 0, 0 ) }
}

eval { DateTime::Lite->from_object( object => (bless {}, 'DT::Object'), locale => 'en_US' ) };
is( $@, '', 'make sure constructor accepts locale parameter' );

eval { DateTime::Lite->new( year => 100, locale => DateTime::Lite::Locale->load('en_US') ) };
is( $@, '', 'make sure constructor accepts locale parameter as object' );

local $DateTime::Lite::DefaultLocale = 'it';
is( DateTime::Lite->now->locale->id, 'it', 'default locale should now be "it"' );

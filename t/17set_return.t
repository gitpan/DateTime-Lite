#!/usr/bin/perl -w

use strict;

use Test::More tests => 7;

use DateTime::Lite qw(Arithmetic);
use DateTime::Lite::Duration;

{
    my $dt = DateTime::Lite->new( year => 2008, month => 2, day => 28 );
    my $du = DateTime::Lite::Duration->new( years => 1 );

    my $p;

    $p = $dt->set( year => 1882 );
    is( DateTime::Lite->compare( $p, $dt ), 0, "set() returns self" );

    $p = $dt->set_time_zone( 'Australia/Sydney' );
    is( DateTime::Lite->compare( $p, $dt ), 0, "set_time_zone() returns self" );

    $p = $dt->add_duration( $du );
    is( DateTime::Lite->compare( $p, $dt ), 0, "add_duration() returns self" );

    $p = $dt->add( years => 2 );
    is( DateTime::Lite->compare( $p, $dt ), 0, "add() returns self" );


    $p = $dt->subtract_duration( $du );
    is( DateTime::Lite->compare( $p, $dt ), 0, "subtract_duration() returns self" );

    $p = $dt->subtract( years => 3 );
    is( DateTime::Lite->compare( $p, $dt ), 0, "subtract() returns self" );

    $p = $dt->truncate( to => 'day' );
    is( DateTime::Lite->compare( $p, $dt ), 0, "truncate() returns self" );

}

use strict;
use Cwd;
use inc::Module::Install;

my $CLDR_VERSION = $ENV{CLDR_VERSION} || '1.6.1';
my $AUTHOR_MODE  = $ENV{AUTHOR_MODE}  || 
    (-d '.svn' || Cwd::cwd() =~ /\bsvk\b/i || -d '.git');

name('DateTime-Lite');
all_from('lib/DateTime/Lite.pm');

requires 'SelfLoader'; 
requires 'Scalar::Util';
requires 'Time::Local';
if ($^O eq 'MSWin32') {
    requires 'Win32::TieRegistry';
}

# check if we have /something/ in the timezone/locale directory
# XXX FIXME 
if ($AUTHOR_MODE) {
    # XXX FIXME: locale generator should NOT depend on Moose

    if (! -f 'lib/DateTime/Lite/Locale/en_US.dat') {
        my $y_n = prompt("You don't seem to have locale  data generated.\nWould you like to download the cldr database and create them?", "y");
        if ($y_n =~ /^y(?:es)?$/i) {
            system($^X, "tools/locale/update-locales.pl", "--version", $CLDR_VERSION);
        }
    }

    if (! -f 'lib/DateTime/Lite/TimeZone/Asia/Tokyo.dat' ) {
        my $y_n = prompt("You don't seem to have time zone data generated.\nWould you like to download the olson database and create them? (this requires sudo)", "y");
        if ($y_n =~ /^y(?:es)?$/i) {
            system($^X, "tools/timezone/update-timezones.pl");
        }
    }

}

my $postamble = <<"EOM";
CLDR_VERSION=$CLDR_VERSION
EOM

$postamble .= <<'EOM';
timezone:
	$(NOECHO)$(FULLPERLRUN) tools/timezone/update-timezones.pl

locale:
	$(NOECHO)$(FULLPERLRUN) tools/locale/update-locales.pl --version=$(CLDR_VERSION)

benchmark: pure_all
	$(NOECHO)$(FULLPERLRUN) -Mblib tools/benchmark/simple_create.pl

profile: pure_all
	$(NOECHO)$(FULLPERLRUN) -Mblib tools/profile/simple_create.pl

EOM
postamble $postamble;

tests 't/*.t t/*/*.t';
WriteAll;

# TODO: Ask the user which timezones they want.

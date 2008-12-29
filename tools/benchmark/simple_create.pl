use strict;
use Benchmark qw(cmpthese);
use DateTime;
use DateTime::Lite;

print "Benchmarking DateTime $DateTime::VERSION and DateTime::Lite $DateTime::Lite::VERSION\n";
print "   (DateTime is ", $DateTime::IsPurePerl ? "NOT " : "", "using XS -- tweak PERL_DATETIME_PP to change this)\n";

cmpthese(10000, {
    dt => sub {
        DateTime->new(year => 2000, month => 1, day => 1, time_zone => 'Asia/Tokyo')
    },
    dt_lite => sub {
        DateTime::Lite->new(year => 2000, month => 1, day => 1, time_zone => 'Asia/Tokyo')
    }
});
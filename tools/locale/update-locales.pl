#!/user/local/bin/perl

use strict;
use warnings;

use lib "lib";
use lib "tools/lib";

use DateTime::Lite::Tool::Locale::Generator;
DateTime::Lite::Tool::Locale::Generator->new_with_options->run();
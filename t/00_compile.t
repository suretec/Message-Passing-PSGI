use strict;
use warnings;

use Test::More;

use_ok('Log::Stash::PSGI');
use_ok('Plack::App::Log::Stash');
use_ok('Plack::Handler::Log::Stash');

done_testing;


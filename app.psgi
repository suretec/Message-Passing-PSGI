use strict;
use warnings;

use Plack::App::Log::Stash;
use Log::Stash::Output::STDOUT;

Plack::App::Log::Stash->new(output_to => Log::Stash::Output::STDOUT->new)->to_app;


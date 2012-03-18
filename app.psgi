use strict;
use warnings;

use Plack::App::Log::Stash;
use Log::Stash::Output::STDOUT;
use Log::Stash::Filter::T;
use Log::Stash::Output::ZeroMQ;
use Log::Stash::Input::ZeroMQ;

my $app; $app = Plack::App::Log::Stash->new(
    output_to => Log::Stash::Filter::T->new(
        output_to => [
            Log::Stash::Output::STDOUT->new,
            Log::Stash::Output::ZeroMQ->new(
                socket_bind => 'tcp://127.0.0.1:5558',
                socket_type => 'PUSH',
            ),
        ],
    ),
);
$app->to_app;


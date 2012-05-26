use strict;
use warnings;

use Plack::App::Message::Passing;
use Message::Passing::Output::ZeroMQ;
use Message::Passing::Input::ZeroMQ;

my $app; $app = Plack::App::Message::Passing->new(
    output_to => Message::Passing::Output::ZeroMQ->new(
        socket_bind => 'tcp://127.0.0.1:5558',
        socket_type => 'PUSH',
    ),
);
$app->to_app;


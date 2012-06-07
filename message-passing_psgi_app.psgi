use strict;
use warnings;

use Plack::App::Message::Passing;

Plack::App::Message::Passing->new(
    return_address => "tcp://127.0.0.1:5555",
    send_address => "tcp://127.0.0.1:5556",
)->to_app


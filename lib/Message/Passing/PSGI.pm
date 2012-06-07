package Message::Passing::PSGI;
use strict;
use warnings;

our $VERSION = '0.001';
$VERSION = eval $VERSION;

1;

=head1 NAME

Message::Passing::PSGI - ALPHA QUALITY PSGI adaptor for Message::Passing

=head1 SYNOPSIS

    # Run the server
    plackup -s Twiggy -MPlack::App::Message::Passing -e'Plack::App::Message::Passing->new(
        return_address => "tcp://127.0.0.1:5555",
        send_address => "tcp://127.0.0.1:5556",
      )->to_app' 

    # Run your app with the handler
    plackup -s Message::Passing t/testapp.psgi

    http://localhost:5000/

=head1 DESCRIPTION

ALPHA EXPERIMENT

=cut

1;


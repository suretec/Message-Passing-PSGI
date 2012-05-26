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
    plackup -s Twiggy `which log_stash_psgi_app.psgi`

    # Run your app with the handler
    plackup -s Message::Passing t/testapp.psgi

    http://localhost:5000/

=head1 DESCRIPTION

ALPHA EXPERIMENT

=cut

1;


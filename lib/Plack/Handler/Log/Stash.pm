package Plack::Handler::Message::Passing;
use Moose;
use AnyEvent;
use Message::Passing::Output::ZeroMQ;
use Message::Passing::Input::ZeroMQ;
use Message::Passing::Filter::T;
use Message::Passing::Output::STDOUT;
use namespace::autoclean;

with 'Message::Passing::Role::Output';

has app => (
    is => 'rw',
);

has output_to => (
    is => 'ro',
    lazy => 1,
    default => sub {
        Message::Passing::Output::ZeroMQ->new(
            connect => 'tcp://127.0.0.1:5559',
            socket_type => 'PUB',
        );
    },
);

sub consume {
    my ($self, $env) = @_;
    $env->{'psgi.errors'} = \*STDERR;
    open(my $input_fh, '<', \'') or die $!;
    $env->{'psgi.input'} = $input_fh;
    my $reply_to = $env->{'psgix.log.stash.clientid'};
    my $res = $self->app->($env);
    my $return_data = {clientid => $reply_to, response => $res};
    $self->output_to->consume($return_data);
}

sub run {
    my ($self, $app) = @_;
    $self->app($app);
    my $input = Message::Passing::Input::ZeroMQ->new(
        connect => 'tcp://127.0.0.1:5558',
        socket_type => 'PULL',
        output_to => $self,
    );
    AnyEvent->condvar->recv;
}

1;


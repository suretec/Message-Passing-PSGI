package Plack::Handler::Message::Passing;
use Moose;
use AnyEvent;
use Message::Passing::Output::ZeroMQ;
use Message::Passing::Input::ZeroMQ;
use namespace::autoclean;

with 'Message::Passing::Role::Output';

has app => (
    is => 'rw',
);

has [qw/ host port /] => (
    is => 'ro',
);

has output_to => (
    is => 'ro',
    default => sub { {} },
);

sub get_output_to {
    my ($self, $address) = @_;
    $self->output_to->{$address} ||= Message::Passing::Output::ZeroMQ->new(
        connect => $address,
        socket_type => 'PUB',
    );
}

sub consume {
    my ($self, $env) = @_;
    $env->{'psgi.errors'} = \*STDERR;
    open(my $input_fh, '<', \'') or die $!;
    $env->{'psgi.input'} = $input_fh;
    my $clientid = $env->{'psgix.message.passing.clientid'};
    my $reply_to = $env->{'psgix.message.passing.returnaddress'};
    my $res = $self->app->($env);
    my $return_data = {clientid => $clientid, response => $res};
    my $output_to = $self->get_output_to($reply_to);
    $output_to->consume($return_data);
}

sub run {
    my ($self, $app) = @_;
    $self->app($app);
    my $connect_address = sprintf('tcp://%s:%s', $self->host, $self->port);
    warn $connect_address;
    my $input = Message::Passing::Input::ZeroMQ->new(
        connect => $connect_address,
        socket_type => 'PULL',
        output_to => $self,
    );
    AnyEvent->condvar->recv;
}

1;


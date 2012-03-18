package Plack::Handler::Log::Stash;
use Moose;
use AnyEvent;
use Log::Stash::Output::ZeroMQ;
use Log::Stash::Input::ZeroMQ;
use namespace::autoclean;

with 'Log::Stash::Role::Output';

has app => (
    is => 'rw',
);

has output_to => (
    is => 'ro',
    lazy => 1,
    default => sub {
        Log::Stash::Output::ZeroMQ->new(
            connect => 'tcp://127.0.0.1:5559',
            socket_type => 'PUB',
        );
    },
);

sub consume {
    my ($self, $env) = @_;
    $env->{'psgi.errors'} = \*STDERR;
    my $input = '';
    open(my $input_fh, '<', \$input) or die $!;
    $env->{'psgi.input'} = $input_fh;
    my $reply_to = $env->{'psgix.log.stash.clientid'};
    my $res = $self->app->($env);
    use Data::Dumper;
    warn Dumper($res);
    $self->output_to->consume({clientid => $reply_to, response => $res});
}

sub run {
    my ($self, $app) = @_;
    $self->app($app);
    my $input = Log::Stash::Input::ZeroMQ->new(
        connect => 'tcp://127.0.0.1:5558',
        socket_type => 'PULL',
        output_to => $self,
    );
    AnyEvent->condvar->recv;
}

1;


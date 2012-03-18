package Plack::Handler::Log::Stash;
use Moose;
use AnyEvent;
use Log::Stash::Output::ZeroMQ;
use Log::Stash::Input::ZeroMQ;
use Log::Stash::Filter::T;
use Log::Stash::Output::STDOUT;
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
    warn("GOT " . Dumper($env));
    $env->{'psgi.errors'} = \*STDERR;
    my $input = '';
    open(my $input_fh, '<', \$input) or die $!;
    $env->{'psgi.input'} = $input_fh;
    my $reply_to = $env->{'psgix.log.stash.clientid'};
    my $res = $self->app->($env);
    use Data::Dumper;
    my $return_data = {clientid => $reply_to, response => $res};
    warn "RETUWN " . Dumper($return_data);
    $self->output_to->consume($return_data);
}

sub run {
    my ($self, $app) = @_;
    $self->app($app);
    my $input = Log::Stash::Input::ZeroMQ->new(
        connect => 'tcp://127.0.0.1:5558',
        socket_type => 'PULL',
        output_to => Log::Stash::Filter::T->new(
            output_to => [
                Log::Stash::Output::STDOUT->new,
                $self,
            ],
        ),
    );
    warn("SETUP INPUT");
    AnyEvent->condvar->recv;
}

1;


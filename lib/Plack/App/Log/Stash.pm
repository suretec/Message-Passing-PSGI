package Plack::App::Log::Stash;
use Moose;
use Scalar::Util qw/ refaddr /;
use namespace::autoclean;

with qw/
    Log::Stash::Role::Input
    Log::Stash::Role::Output
/;

has in_flight => (
    isa => 'HashRef',
    is => 'ro',
    default => sub { {} },
);

sub to_app {
    my $self = shift;
    sub {
        my $base_env = shift;
        my $env = {%$base_env};
        die("You need to use a non-blocking server, such as Twiggy")
            unless delete $env->{'psgi.nonblocking'};
        delete $env->{'psgi.errors'};
        delete $env->{'psgix.io'};
        delete $env->{'psgi.input'};
        delete $env->{'psgi.streaming'};
        $env->{'psgix.log.stash.clientid'} = refaddr($base_env);
        $self->output_to->consume($env);
        return sub {
            my $responder = shift;
            $self->in_flight->{refaddr($base_env)} = $responder;
        }
    };
}

sub consume {
    my ($self, $message) = @_;
    warn("GOT MESSAGE BACK");
    my $clientid = $message->{clientid};
    delete($self->in_flight->{$clientid})->($message->{response});
}

__PACKAGE__->meta->make_immutable;
1;


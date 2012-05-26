package Plack::App::Message::Passing;
use Moose;
use Scalar::Util qw/ weaken refaddr /;
use namespace::autoclean;

with qw/
    Message::Passing::Role::Input
    Message::Passing::Role::Output
/;

has input => (
    is => 'ro',
    lazy => 1,
    default => sub {
        my $self = shift;
        weaken($self);
        Message::Passing::Input::ZeroMQ->new(
            socket_bind => 'tcp://127.0.0.1:5559',
            socket_type => 'SUB',
            output_to => $self,
        );
    },
);

has in_flight => (
    isa => 'HashRef',
    is => 'ro',
    default => sub { {} },
);

sub to_app {
    my $self = shift;
    $self->input; # Build attribute.
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
    my $clientid = $message->{clientid};
    delete($self->in_flight->{$clientid})->($message->{response});
}

__PACKAGE__->meta->make_immutable;
1;


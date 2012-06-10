package Plack::App::Message::Passing;
use Moose;
use Scalar::Util qw/ weaken refaddr /;
use Message::Passing::Input::ZeroMQ;
use Message::Passing::Output::ZeroMQ;
use JSON qw/ encode_json decode_json /;
use namespace::autoclean;

with qw/
    Message::Passing::Role::Input
    Message::Passing::Role::Output
/;

has return_address => (
    isa => 'Str',
    is => 'ro',
    required => 1,
);

has input => (
    is => 'ro',
    lazy => 1,
    default => sub {
        my $self = shift;
        weaken($self);
        Message::Passing::Input::ZeroMQ->new(
            socket_bind => $self->return_address,
            socket_type => 'SUB',
            output_to => $self,
        );
    },
);

has send_address => (
    isa => 'Str',
    is => 'ro',
    required => 1,
);

has '+output_to' => (
    lazy => 1,
    default => sub {
        my $self = shift;
        Message::Passing::Output::ZeroMQ->new(
            socket_bind => $self->send_address,
            socket_type => 'PUSH',
        );
    },
);

has in_flight => (
    isa => 'HashRef',
    is => 'ro',
    default => sub { {} },
);

sub BUILD {
    my $self = shift;
    $self->input; # Build attribute.
}

sub _handle_request {
    my ($self, $base_env) = @_;
    weaken($self);
    my $env = {%$base_env};
    die("You need to use a non-blocking server, such as Twiggy")
        unless delete $env->{'psgi.nonblocking'};
    delete $env->{'psgi.errors'};
    delete $env->{'psgix.io'};
    my $input_fh = delete $env->{'psgi.input'};
    my $input = '';
    my $len = 0;
    do {
        $len = $input_fh->read(my $buf, 4096);
        $input .= $buf;
    } while ($len);
    $env->{'psgi.input'} = $input;
    delete $env->{'psgi.streaming'};
    $env->{'psgix.message.passing.clientid'} = refaddr($base_env);
    $env->{'psgix.message.passing.returnaddress'} = $self->return_address;
    $self->output_to->consume(encode_json $env);
    return sub {
        my $responder = shift;
        $self->in_flight->{refaddr($base_env)} = [$base_env, $responder];
    }
}

sub to_app {
    my $self = shift;
    weaken($self);
    sub {
        my $env = shift;
        $self->_handle_request($env);
    };
}

sub consume {
    my ($self, $message) = @_;
    $message = decode_json $message;
    my $clientid = $message->{clientid};
    my ($env, $responder) = @{ delete($self->in_flight->{$clientid}) };
    if (length $message->{errors}) {
        $env->{'psgi.errors'}->print($message->{errors});
    }
    $responder->($message->{response});
}

__PACKAGE__->meta->make_immutable;
1;


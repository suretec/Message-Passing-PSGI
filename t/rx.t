use strict;
use warnings;
use Test::More 0.88;
use Message::Passing::Output::Test;
use JSON qw/ decode_json encode_json /;

use_ok 'Plack::Handler::Message::Passing';

our $reply_to;
local $reply_to = Message::Passing::Output::Test->new;

{
    package TestHandler;
    use Moose;

    extends 'Plack::Handler::Message::Passing';

    sub get_output_to { $::reply_to }

    no Moose;
}
my $called = 0;
my $h =  TestHandler->new(
    app => sub {
        $called++;
        my $env = shift;
        ::is ref($env), 'HASH';
        my $input = $env->{'psgi.input'};
        ::ok($input);
        ::is $input->read(my $buf, 4096), 6;
        ::is $buf, 'foobar';
        ::is $input->read($buf, 4096), 0;
        ::ok $env->{'psgi.errors'}->print('SOME ERROR');
        return [ 200, [], ['foo'] ];
    }
);
ok $h;

my $env = {
    'psgix.message.passing.clientid' => 1,
    'psgix.message.passing.returnaddress' => 'tcp://127.0.0.1:5222',
    'psgi.input' => 'foobar',
};

$h->consume(encode_json $env);
is $reply_to->message_count, 1;
is_deeply [map { decode_json $_ } $reply_to->messages],
    [{clientid => 1, response => [ 200, [], ["foo"] ], errors => 'SOME ERROR'}];
is $called, 1;

done_testing;


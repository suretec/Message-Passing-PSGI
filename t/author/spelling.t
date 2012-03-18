use strict;
use warnings;
use Test::More;
use Test::Spelling;

add_stopwords(qw(
    Starman
    ZeroMQ
    API
    Affero
    FCGI
    JSON
    Tomas
    Doran
    t0m
    Jorden
    Logstash
    Sissel
    Suretec
    TODO
    STDIN
    STDOUT
    STDERR
    logstash
));
set_spell_cmd('aspell list -l en');
all_pod_files_spelling_ok();

done_testing();

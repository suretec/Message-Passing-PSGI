use strict;
use warnings;
use inc::Module::Install;

all_from 'lib/Log/Stash/PSGI.pm';

license 'AGPL_3';

requires 'Plack';
requires 'Log::Stash';
requires 'Log::Stash::ZeroMQ';
requires 'AnyEvent';
requires 'Moose';
requires 'namespace::autoclean';

author_requires 'Test::Pod' => '1.14';
author_requires 'Test::NoTabs';
author_requires 'Test::Pod::Coverage' => '1.04';
author_requires 'Pod::Coverage' => '0.19';
author_requires 'Pod::Coverage::TrustPod';
author_requires 'Test::Spelling';

author_tests 't/author';

install_script 'script/log_stash_psgi_app.psgi';

if ($Module::Install::AUTHOR) {
    system("pod2text lib/Log/Stash/PSGI.pm > README")
        and die $!;
}

WriteAll;


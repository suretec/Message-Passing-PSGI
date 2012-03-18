use strict;
use warnings;
use Test::More;

use Pod::Coverage 0.19;
use Test::Pod::Coverage 1.04;

my @modules = all_modules;
our @private = ( 'BUILD' );
foreach my $module (@modules) {
    local @private = (@private, 'expand_class_name', 'make') if $module =~ /^Log::Stash::DSL::Factory$/;

    pod_coverage_ok($module, {
        also_private   => \@private,
        coverage_class => 'Pod::Coverage::TrustPod',
    });
}

done_testing;


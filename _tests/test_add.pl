#! /usr/bin/perl
#-----------------------------------------------------------------------------------------------

use strict;
use warnings;

use JSON;
use Redis::JobQueue;

my $connection_string = '127.0.0.1:6379';
my $jq = Redis::JobQueue->new( redis => $connection_string );

my $job = $jq->add_job({
    queue       => 'xxx',
    workload    => 'test 11111111',
    expire      => 60 * 5,
});


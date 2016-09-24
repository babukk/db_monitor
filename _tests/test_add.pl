#! /usr/bin/perl
#-----------------------------------------------------------------------------------------------

use strict;
use warnings;

use JSON;
use Redis::JobQueue;
use Data::Dumper;
use RedisDB;

my $connection_string = '127.0.0.1:6379';
my $jq = Redis::JobQueue->new( redis => $connection_string );

my $job = $jq->add_job({
    queue       => 'xxx',
    workload    => 'test 11111111',
    expire      => 60 * 5,
});

print Dumper($job);

print $job->id, "\n";

my $redis = RedisDB->new(host => 'localhost', port => 6379);

$redis->set('vasya-pupkin@localhost', $job->id);
$redis->expire('vasya-pupkin@localhost', $job->expire);

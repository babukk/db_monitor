#! /usr/bin/perl
#-----------------------------------------------------------------------------------------------

use strict;
use warnings;

use JSON;
use Data::Dumper;
use RedisDB;


my $redis = RedisDB->new(host => 'localhost', port => 6379);

print $redis->get('vasy-pupkin@localhost'), "\n";

print $redis->expire('vasy-pupkin@localhost'), "\n";

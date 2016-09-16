#! /usr/bin/perl
#-----------------------------------------------------------------------------------------------

use strict;
use warnings;

use Redis::JobQueue;

my $connection_string = '127.0.0.1:6379';
my $jq = Redis::JobQueue->new( redis => $connection_string );

while (my $job = $jq->get_next_job(
    queue       => 'xxx',
    blocking    => 1,
)) {
    $job->status( 'working' );
    $jq->update_job( $job );

    xxx( $job );

    $job->status( 'completed' );
    $jq->update_job( $job );
}

# ----------------------------------------------------------------

sub xxx {
    my $job = shift;

    my $workload = ${ $job->workload };
    $job->result( 'XXX JOB result comes here' );
}

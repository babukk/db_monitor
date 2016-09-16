#! /usr/bin/perl
#-----------------------------------------------------------------------------------------------

use strict;
use warnings;

use Redis::JobQueue;

my $connection_string = '127.0.0.1:6379';
my $jq = Redis::JobQueue->new( redis => $connection_string );


my $id = $ARGV[0];
my $status = $jq->get_job_data( $id, 'status' );
 
if ($status eq 'completed') {
    my $job = $jq->load_job( $id );

    $jq->delete_job( $id );
    print 'Job result: ', ${ $job->result };
}
else {
    print "Job is not complete, has current '$status' status";
}


use RedisDB;
use Data::Dumper;

my $job_queue = { host => 'localhost', port => 6379, utf8 => 1, };

my $queue = RedisDB->new($job_queue);

my @xxx = $queue->scan_all;
print Dumper(@xxx);

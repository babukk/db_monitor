#! /usr/bin/perl
#-----------------------------------------------------------------------------------------------

use strict;
use warnings;

use RedisDB;

use DbMonitor;
use DbConfig;
use Data::Dumper;

my @monitor_pull = ();
my $conf = $DbConfig::config;

=cut
my $job_queue;
eval {
    $job_queue = RedisDB->new(host => 'localhost', port => 6379);
};
if ($@) {
    print STDERR "Redis: " . $@, "\n";
    exit(1);
}
=cut

# print  Dumper($conf);

foreach my $conf_key (keys %{$conf->{ 'databases' }}) {

    print "starting monitor for ", $conf_key, "\n";

    my $monitor_instance = DbMonitor->new({
        'config'        => $conf,
        'db_config'     => $conf->{ 'databases' }->{ $conf_key },
        'monitor_name'  => $conf_key,
        'log_conf_file' => 'etc/log4perl.conf',
        'job_queue'     => { host => 'localhost', port => 6379, },
    });

    $monitor_instance->startMonitor;
    push(@monitor_pull, $monitor_instance);
}

# print Dumper(@monitor);

while (1) {
    sleep 1;
}

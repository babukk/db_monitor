#! /usr/bin/perl
#-----------------------------------------------------------------------------------------------

use strict;
use warnings;

use RedisDB;

use DbConfig;
use DbMonitor;
use DbMailer;
# use utf8;
use Data::Dumper;

my @monitor_pull = ();
my $conf = $DbConfig::config;

# binmode( STDOUT,':utf8' );
# print  Dumper($conf);

foreach my $conf_key (keys %{$conf->{ 'databases' }}) {

    # print "starting monitor for ", $conf_key, "\n";

    my $monitor_instance = DbMonitor->new({
        'config'        => $conf,
        'db_config'     => $conf->{ 'databases' }->{ $conf_key },
        'monitor_name'  => $conf_key,
        'log_conf_file' => 'etc/log4perl.conf',
        'job_queue'     => { host => 'localhost', port => 6379, utf8 => 1, },
    });

    $monitor_instance->startMonitor;
    push(@monitor_pull, $monitor_instance);
}

my $mailer_proc = DbMailer->new({
        'config'               => $conf,
        'mailer_repeat_period' => $conf->{ 'mailer_repeat_period' },
        'log_conf_file'        => 'etc/log4perl.conf',
        'job_queue'            => { host => 'localhost', port => 6379, utf8 =>1, },
});

$mailer_proc->startProc;

# print Dumper(@monitor);

while (1) {
    sleep 1;
}

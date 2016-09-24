#! /usr/bin/perl
#-----------------------------------------------------------------------------------------------

use strict;
use warnings;

use DbMonitor;
use DbConfig;
use Data::Dumper;

my @monitor_pull = ();
my $conf = $DbConfig::config;

# print  Dumper($conf);

foreach my $conf_key (keys %{$conf->{ 'databases' }}) {

    print "starting monitor for ", $conf_key, "\n";

    my $monitor_instance = DbMonitor->new({
        'config'        => $conf,
        'db_config'     => $conf->{ 'databases' }->{ $conf_key },
        'monitor_name'  => $conf_key,
        'log_conf_file' => 'etc/log4perl.conf',
    });

    $monitor_instance->startMonitor;
    push(@monitor_pull, $monitor_instance);
}

# print Dumper(@monitor);

while (1) {
    sleep 1;
}

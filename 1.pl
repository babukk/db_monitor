#! /usr/bin/perl
#-----------------------------------------------------------------------------------------------

use strict;
use warnings;

use DbMonitor;
use DbConfig;
use Data::Dumper;

my @monitor = ();
my $conf = $DbConfig::config;

# print  Dumper($conf);

foreach my $conf_key (keys %{$conf}) {
    print $conf_key, "\n";
    my $monitor_instance = DbMonitor->new({'config' => $conf->{ $conf_key }, 'monitor_name' => $conf_key,});
    $monitor_instance->startMonitor;
    push(@monitor, $monitor_instance);
}

# print Dumper(@monitor);

while (1) {

    sleep 1;
}

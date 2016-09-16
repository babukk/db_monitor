package DbProc;

use strict;
use warnings;

use DBI;
use threads;
use Data::Dumper;

# ----------------------------------------------------------------------------------------------------------------------

sub new {
    my ($class, $params) = @_;

    my $self;

    while (my ($k, $v) = each %{$params}) {
        $self->{ $k } = $v;
    }

    bless $self, $class;

    return $self;
}

# ----------------------------------------------------------------------------------------------------------------------

sub startProc {
    my ($self) = @_;

    $self->{ 'thread' } = threads->create(sub{ $self->threadProc; });

    return;
}

# ----------------------------------------------------------------------------------------------------------------------

sub threadProc {
    my ($self) = @_;

    # print Dumper($self);

    while (1) {
        print "thread: " . $self->{ 'monitor_name' } . "\n";
        sleep $self->{ 'repeat_period' };
    }

    return;
}






1;


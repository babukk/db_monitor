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

    # $self->{ 'thread' } = threads->create(\$self->threadProc);
    $self->{ 'thread' } = threads->create(sub{ $self->threadProc; });
    # $self->{ 'thread' }->detach;
}

# ----------------------------------------------------------------------------------------------------------------------

sub threadProc {
    my ($self) = @_;

    while (1) {
        print "thread: " . $self->{ 'monitor_name' } . "\n";
        sleep $self->{ 'repeat_period' };
    }
}

1;


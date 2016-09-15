package DbMonitor;

use strict;
use warnings;

use DBI;
use DbProc;
use Data::Dumper;

# ----------------------------------------------------------------------------------------------------------------------

sub new {
    my ($class, $params) = @_;

    my $self;

    while (my ($k, $v) = each %{$params}) {
        $self->{ $k } = $v;
    }

    $self->{ 'db_proc' } = DbProc->new({
        'dbh' => $self->{ 'dbh' },
        'monitor_name' => $self->{ 'monitor_name' },
        'repeat_period' => $self->{ 'config' }->{ 'repeat_period' },
     });

    bless $self, $class;

    return $self;
}

# ----------------------------------------------------------------------------------------------------------------------

sub dbConnect {
    my ($self) = @_;

    $self->{ 'dbh' } = DBI->connect($self->{ 'config' }->{ 'db_name' }, $self->{ 'config' }->{ 'schema' },
                                    $self->{ 'config' }->{ 'password' });
}

# ----------------------------------------------------------------------------------------------------------------------

sub startMonitor{
    my ($self) = @_;

    $self->dbConnect;

    $self->{ 'db_proc' }->startProc;
}

1;

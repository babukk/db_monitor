package DbMailer;

use strict;
use warnings;

use JSON;
use MIME::Lite;
use MIME::Base64;
use Encode qw( _utf8_off );
# use Data::Dumper;

# ----------------------------------------------------------------------------------------------------------------------

sub new {
    my ($class, $params) = @_;

    my $self;

    while (my ($k, $v) = each %{$params}) {
        $self->{ $k } = $v;
    }

    bless $self, $class;

    if ($self->{ 'log_conf_file' }) {
        use Log::Log4perl;
        use Data::Dumper;

        $self->{ 'logger' } = Log::Log4perl->get_logger();
        Log::Log4perl::init($self->{ 'log_conf_file' });
    }

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
        print "thread (mailer): " . $self->{ 'monitor_name' } . "\n";

        $self->executeJobs;

        sleep $self->{ 'mailer_repeat_period' };
    }

    return;
}

# ----------------------------------------------------------------------------------------------------------------------

sub executeJobs {
    my ($self) = @_;

    foreach my $job_key (keys %{$self->{ 'config' }->{ 'databases' }}) {
        print "---> monitor = " . $job_key, "\n";
    }
    return;
}

# ----------------------------------------------------------------------------------------------------------------------

sub getJob {
    my ($self, $key) = @_;

    return;
}

# ----------------------------------------------------------------------------------------------------------------------

sub markJobDone {
    my ($self, $key) = @_;

    return;
}



# ----------------------------------------------------------------------------------------------------------------------

sub execJob {
    my ($self, $key) = @_;

    return;
}

1;

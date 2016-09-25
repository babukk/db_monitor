package DbMailer;

use strict;
use warnings;

use JSON;
use MIME::Lite;
use MIME::Base64;
use Encode qw( _utf8_off );
use POSIX qw( strftime );
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

    $self->{ 'job_queue' } = RedisDB->new($self->{ 'job_queue' });

    while (1) {
        $self->executeJobs;
        sleep $self->{ 'mailer_repeat_period' };
    }

    return;
}

# ----------------------------------------------------------------------------------------------------------------------

sub executeJobs {
    my ($self) = @_;

    foreach my $job_key (keys %{$self->{ 'config' }->{ 'databases' }}) {
        # print "---> monitor key = " . $job_key, "\n";
        # print Dumper($self->{ 'job_queue' });
        # print Dumper($self->getJob($job_key));

        my $job;
        eval {
            my $job_text = $self->getJob($job_key);
            if ($job_text) {
                $job = JSON->new->allow_nonref->decode($job_text);
                if ($job) {
                    # print "job => " . Dumper($job);
                    $self->execJob($job_key);
                    $self->markJobDone($job_key);
                }
            }
        };
        if ($@) {
            $self->{ 'logger' }->error('DbMailer::executeJobs: ' . $@)  if ($self->{ 'logger' });
        }
    }
    return;
}

# ----------------------------------------------------------------------------------------------------------------------

sub getJob {
    my ($self, $key) = @_;

    return $self->{ 'job_queue' }->get($key);
}

# ----------------------------------------------------------------------------------------------------------------------

sub markJobDone {
    my ($self, $key) = @_;

    my $job;
    eval {
        $job = JSON->new->allow_nonref->decode($self->getJob($key));
        if ($job) {
            $job->{ 'status' } = 'done';
            $job->{ 'date_executed' } = strftime('%Y-%m-%d %H:%M:%S', localtime);
            my $job_text = JSON->new->allow_nonref->encode($job);
            $self->{ 'job_queue' }->set($key, $job_text);
            $self->{ 'job_queue' }->expire($key, $self->{ 'config' }->{ 'job_expire_time' });
        }
    };
    if ($@) {
        $self->{ 'logger' }->error('DbMailer::markJobDone: ' . $@)  if ($self->{ 'logger' });
    }

    return;
}

# ----------------------------------------------------------------------------------------------------------------------

sub execJob {
    my ($self, $key) = @_;

    my $job;
    eval {
        $job = JSON->new->allow_nonref->decode($self->getJob($key));
        if ($job) {
            ;
        }
    };
    if ($@) {
        $self->{ 'logger' }->error('DbMailer::execJob: ' . $@)  if ($self->{ 'logger' });
    }

    return;
}

1;

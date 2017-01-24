package DbMailer;

use strict;
use warnings;

use JSON::XS;
use MIME::Lite;
use MIME::Base64;
use Encode qw( _utf8_off _utf8_on encode decode );
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

    my $all_keys = $self->{ 'job_queue' }->scan_all;

    foreach my $job_key (@{$all_keys}) {

        my $job;
        eval {
            my $job_text = $self->getJob($job_key);
            if ($job_text) {
                $self->{ 'logger' }->info('executeJobs: job_text => ' . $job_text)  if ($self->{ 'logger' });
                $job = JSON::XS->new();
                $job->allow_nonref(1);
                $job = $job->decode($job_text);

                if (($job) && ($job->{ 'status' } eq 'new')) {
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
        $job = JSON::XS->new();
        $job->allow_nonref(1);
        $job = $job->decode($self->getJob($key));

        if ($job) {
            $job->{ 'status' } = 'done';
            $job->{ 'date_executed' } = strftime('%Y-%m-%d %H:%M:%S', localtime);
            my $job_text = JSON::XS->new();
            $job_text->allow_nonref(1);
            $job_text = $job_text->encode($job);
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
        my $job = JSON::XS->new();
        $job->allow_nonref(1);
        $job = $job->decode($self->getJob($key));

        if ($job) {
            $self->sendEmail($job);
        }
    };
    if ($@) {
        $self->{ 'logger' }->error('DbMailer::execJob: ' . $@)  if ($self->{ 'logger' });
    }

    return;
}

# ----------------------------------------------------------------------------------------------------------------------

sub sendEmail {
    my ($self, $job) = @_;

    my $mail_subject = $job->{ 'message_subject' };
    my $message_text = $job->{ 'message_text' };
    $message_text = decode( 'utf8', $message_text);

    $mail_subject = MIME::Base64::encode_base64( $mail_subject, '' );
    $mail_subject = "=?UTF-8?B?" . $mail_subject . "?=";

    my  $msg = MIME::Lite->new(
        From     => $self->{ 'config' }->{ 'email_from' },
        To       => join(',', (@{$self->{ 'config' }->{ 'email_notify_list' }})),
        Subject  => $mail_subject,
        Type     => 'multipart/mixed',
    );
    $msg->attach(
        Type => 'text/html; charset=utf-8',
        Data => $message_text,
    );
    MIME::Lite->send( 'smtp', $self->{ 'config' }->{ 'smtp_host' }, Timeout => 60 );
    # $self->{ 'logger' }->info('DbMailer::sendemail: ' . $job->{ 'mail_subject' } . '; ' . $message_text)  if ($self->{ 'logger' });
    $msg->send();
    undef  $msg;

    return;
}

1;

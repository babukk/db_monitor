package DbProc;

use strict;
use warnings;

use threads;
use DBI;
use RedisDB;
use JSON::XS;
use POSIX qw( strftime );
use Time::HiRes qw/time/;
use HTML::Template;
use Data::Dumper;

use constant    BROKEN_JOBS             => 'BROKEN_JOBS';
use constant    NON_SCHEDULED_JOBS      => 'NON_SCHEDULED_JOBS';
use constant    WAITING_SESSIONS        => 'WAITING_SESSIONS';
use constant    BLOCKING_SESSIONS       => 'BLOCKING_SESSIONS';
use constant    DB_LINKS                => 'DB_LINKS';

# -----------------------------------------------------------------------------------------------------------------------

sub new {
    my ($class, $params) = @_;

    my $self;

    while (my ($k, $v) = each %{$params}) {
        $self->{ $k } = $v;
    }

    bless $self, $class;

    return $self;
}

# -----------------------------------------------------------------------------------------------------------------------

sub startProc {
    my ($self) = @_;

    $self->{ 'thread' } = threads->create(sub{ $self->threadProc; });
    # $self->{ 'thread' }->join;

    return;
}

# -----------------------------------------------------------------------------------------------------------------------

sub threadProc {
    my ($self) = @_;

    $self->dbConnect;

    while (1) {
        $self->checkBrokenJobs;
        $self->checkNonScheduledJobs;
        $self->checkSessions;
        $self->checkDbLinks;
        sleep $self->{ 'repeat_period' };
    }

    return;
}

# -----------------------------------------------------------------------------------------------------------------------

sub dbConnect {
    my ($self) = @_;

    eval {
        $ENV{ 'ORACLE_HOME' } = $self->{ 'db_config' }->{ 'ORACLE_HOME' }  if $self->{ 'db_config' }->{ 'ORACLE_HOME' };
        $self->{ 'dbh' } = DBI->connect($self->{ 'db_config' }->{ 'db_name' }, $self->{ 'db_config' }->{ 'schema' },
                                        $self->{ 'db_config' }->{ 'password' });
    };
    if ($@) {
        $self->{ 'logger' }->info($self->{ 'monitor_name' } . 'DbProc.pm. SQL error: ' . $@)  if $self->{ 'logger' };
    }

    return;
}

# -----------------------------------------------------------------------------------------------------------------------
# checkBrokenJobs()
# Описание: Джобы в статусе BROKEN
# -----------------------------------------------------------------------------------------------------------------------

sub checkBrokenJobs {
    my ($self) = @_;

    my $sth;

    # print "path = " . $self->{ 'tmpl_path' }, "\n";

    my $template = HTML::Template->new(filename => $self->{ 'tmpl_path' } . '/broken_jobs.tmpl', die_on_bad_params => 0);
    my @jobs = ();

    eval {
        $sth = $self->{ 'dbh' }->prepare("

            SELECT  job, sysdate, last_date, failures
              FROM  user_jobs
             WHERE  BROKEN = 'N' "
        );
        $sth->execute;
        while (my ($job, $sysdate, $last_date, $failures) = $sth->fetchrow_array) {
            my %data = ();
            $data{ JOB } = $job;
            $data{ SYSDATE } = $sysdate;
            $data{ LAST_DATE } = $last_date;
            $data{ FAILURES } = $failures;
            push(@jobs, \%data);
        }
        $sth->finish;
        undef $sth;
    };
    if ($@)  {
        $self->{ 'logger' }->error('DbProc::checkBrokenJobs. SQL error: ' . $@)  if ($self->{ 'logger' });
    }

    if (@jobs) {
        $template->param({ JOB_LIST => \@jobs, });
        $self->addIssueToQueue({
            'type' => BROKEN_JOBS,
            'key' => $self->{ 'monitor_name' } . ':' . BROKEN_JOBS,
            'message_subject' => $self->{ 'monitor_name' } . ' -> JOBS',
            'message_text' => $template->output,
        });
        # $self->{ 'logger' }->info($self->{ 'monitor_name' } . '. Broken jobs: ' . $job_list)  if $self->{ 'logger' };
    }

    undef $template;

    return;
}

# ----------------------------------------------------------------------------------------------------------------------
# checkNonScheduledJobs()
# Описание: Джоб не запущен по расписанию (NEXT_DATE меньше sysdate и THIS_DATE не заполнен)
# ----------------------------------------------------------------------------------------------------------------------

sub checkNonScheduledJobs {
    my ($self) = @_;

    my $issue = 0;

    my $sth;
    my $template = HTML::Template->new(filename => $self->{ 'tmpl_path' } . '/non_scheduled_jobs.tmpl', die_on_bad_params => 0);
    my @jobs = ();

    eval {
        $sth = $self->{ 'dbh' }->prepare( "

            SELECT  job, sysdate, last_date, next_date, failures
              FROM  user_jobs
             WHERE  -- next_date < sysdate - 1 / 24 / 60 / 10
                    next_date < sysdate
               AND  this_date  IS NULL "
        );
        $sth->execute;
        while (my ($job, $sysdate, $last_date, $next_date, $failures) = $sth->fetchrow_array) {
            my %data = ();
            $data{ JOB } = $job;
            $data{ SYSDATE } = $sysdate;
            $data{ LAST_DATE } = $last_date;
            $data{ NEXT_DATE } = $next_date;
            $data{ FAILURES } = $failures;
            push(@jobs, \%data);
        }
        $sth->finish;
        undef $sth;
    };
    if ($@)  {
        $self->{ 'logger' }->error('DbProc::checkNonScheduledJobs. SQL error: ' . $@)  if ($self->{ 'logger' });
    }

    if ($issue) {
        $template->param({ JOB_LIST => \@jobs, });
        $self->addIssueToQueue({
            'type' => NON_SCHEDULED_JOBS,
            'key' => $self->{ 'monitor_name' } . ':' . NON_SCHEDULED_JOBS,
            'message_subject' => $self->{ 'monitor_name' } . ' -> JOBS',
            'message_text' => 'Следующие джобы не были запущены по расписанию: <b>' . $job_list . '</b>',
        });
        $self->{ 'logger' }->info($self->{ 'monitor_name' } . '. Non-scheduled jobs: ' . $job_list)  if $self->{ 'logger' };
    }

    return;
}

# -----------------------------------------------------------------------------------------------------------------------

sub checkDbLinks {
    my ($self) = @_;

    return;
}

# -----------------------------------------------------------------------------------------------------------------------

sub checkDbLink {
    my ($self, $dblink) = @_;

    my $sth;
    my $rslt = 0;
    eval {
        local $SIG{ALRM} = sub { die "alarm\n" };
        alarm $self->{ 'config' }->{ 'db_link_check_timeout' };
        $sth = $self->{ 'dbh' }->prepare(" SELECT  count(*)  FROM  dual@" . $dblink);
        $sth->execute;
        $sth->finish;
        undef $sth;
        $rslt = 1;
        alarm 0;
    };
    if ($@)  {
        if ($@ eq "alarm\n") {
            $self->{ 'logger' }->error('DbProc::checkDbLink. Timeout when checking dblink ' . $dblink)  if ($self->{ 'logger' });
        }
        $self->{ 'logger' }->error('DbProc::checkDbLink. SQL error: ' . $@)  if ($self->{ 'logger' });
        $rslt = 0;
    }

    return $rslt;
}

# -----------------------------------------------------------------------------------------------------------------------

sub checkSessions {
    my ($self) = @_;


    return;
}

# -----------------------------------------------------------------------------------------------------------------------

sub addIssueToQueue {
    my ($self, $param) = @_;

    my $params = ();
    $params->{ 'id' } = sprintf "%d", Time::HiRes::time * 1000000;
    $params->{ 'message_text' } = $param->{ 'message_text' };
    $params->{ 'type' } = $param->{ 'type' };
    $params->{ 'status' } = 'new';
    $params->{ 'message_subject' } = $param->{ 'message_subject' };
    $params->{ 'date_created' } = strftime('%Y-%m-%d %H:%M:%S', localtime);
    $params->{ 'date_executed' } = '';

    my $data = JSON::XS->new();
    $data->allow_nonref(1);
    $data = $data->encode($params);

    eval {
        my $job_queue = RedisDB->new($self->{ 'job_queue' });
        my $job_data = $job_queue->get($param->{ 'key' });

        if ($job_data) {
            my $job_exists = JSON::XS->new();
            $job_exists->allow_nonref(1);
            $job_exists = $job_exists->decode($job_data);

            if ($job_exists->{ 'type' }) {
                if ($job_exists->{ 'type' } ne $params->{ 'type' }) {
                    $job_queue->set($param->{ 'key' }, $data);
                    $job_queue->expire($param->{ 'key' }, $self->{ 'config' }->{ 'job_expire_time' });
                }
            }
        }
        else {
            $job_queue->set($param->{ 'key' }, $data);
            $job_queue->expire($param->{ 'key' }, $self->{ 'config' }->{ 'job_expire_time' });
        }

        undef $job_queue;
        undef $job_data;
    };
    if ($@) {
        $self->{ 'logger' }->error('DbProc.pm: Redis: ' . $@)  if ($self->{ 'logger' });
    }

    undef $data;
    undef $params;

    return;
}

1;

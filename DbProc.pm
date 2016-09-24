package DbProc;

use strict;
use warnings;

use threads;
use DBI;
use Redis::JobQueue;
use RedisDB;
use JSON qw( encode_json );
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
    # $self->{ 'thread' }->join;

    return;
}

# ----------------------------------------------------------------------------------------------------------------------

sub threadProc {
    my ($self) = @_;

    # print Dumper($self);

    $self->dbConnect;

    while (1) {
        print "thread: " . $self->{ 'monitor_name' } . "\n";

        $self->checkBrokenJobs;
        $self->checkNonScheduledJobs;
        $self->checkSessions;
        $self->checkDbLinks;
        sleep $self->{ 'repeat_period' };
    }

    return;
}

# ----------------------------------------------------------------------------------------------------------------------

sub dbConnect {
    my ($self) = @_;

    $self->{ 'dbh' } = DBI->connect($self->{ 'db_config' }->{ 'db_name' }, $self->{ 'db_config' }->{ 'schema' },
                                    $self->{ 'db_config' }->{ 'password' });
    return;
}

# ----------------------------------------------------------------------------------------------------------------------
# checkBrokenJobs()
# Описание: Джоб в статусе BROKEN
# ----------------------------------------------------------------------------------------------------------------------

sub checkBrokenJobs {
    my ($self) = @_;

    # print Dumper($self);
    my $issue = 0;

    my $sth = $self->{ 'dbh' }->prepare( "    SELECT  job  FROM  user_jobs  WHERE  BROKEN = 'Y' " );
    $sth->execute;
    my $job_list;
    while (my (@row) = $sth->fetchrow_array) {
        $job_list .= ' ';
        $job_list .= $row[0];
        $issue ++;
    }
    $sth->finish;
    undef $sth;

    if ($issue) {
        $self->addIssueToQueue({
            'key' => $self->{ 'monitor_name' },
            'text' => 'Broken jobs: ' . $job_list,
        });
        $self->{ 'logger' }->info($self->{ 'monitor_name' } . '. Broken jobs: ' . $job_list)  if $self->{ 'logger' };
    }

    return;
}

# ----------------------------------------------------------------------------------------------------------------------
# checkNonScheduledJobs()
# Описание: Джоб не запущен по расписанию (NEXT_DATE меньше sysdate и THIS_DATE не заполнен)
# ----------------------------------------------------------------------------------------------------------------------

sub checkNonScheduledJobs {
    my ($self) = @_;

    # print Dumper($self);
    my $issue = 0;

    my $sth = $self->{ 'dbh' }->prepare( "    SELECT  job  FROM  user_jobs  WHERE  next_date < sysdate  AND  this_date
                                                                                   IS NULL " );
    $sth->execute;
    my $job_list;
    while (my (@row) = $sth->fetchrow_array) {
        $job_list .= ' ';
        $job_list .= $row[0];
        $issue ++;
    }
    $sth->finish;
    undef $sth;

    if ($issue) {
        $self->{ 'logger' }->info($self->{ 'monitor_name' } . '. Non-scheduled jobs: ' . $job_list)
                                                                                                if $self->{ 'logger' };
    }

    return;
}

# ----------------------------------------------------------------------------------------------------------------------

sub checkDbLinks {
    my ($self) = @_;

    return;
}

# ----------------------------------------------------------------------------------------------------------------------

sub checkSessions {
    my ($self) = @_;


    return;
}

# ----------------------------------------------------------------------------------------------------------------------

sub addIssueToQueue {
    my ($self, $param) = @_;


    my $params = ();
    $params->{ 'text' } = $param->{ 'text' };
    $params->{ 'status' } = 'new';
    $params->{ 'email' } = '';
    $params->{ 'date_created' } = '';
    $params->{ 'date_sent' } = '';
    my $data = JSON->new->allow_nonref->encode($params);

    eval {
        my $job_queue = RedisDB->new($self->{ 'job_queue' });
        $job_queue->set($param->{ 'key' }, $data);
        $job_queue->expire($param->{ 'key' }, 10);
        undef $job_queue;
    };
    if ($@) {
        $self->{ 'logger' }->error('DbProc.pm: Redis: ' . $@);
    }

    return;
}

1;

package DbConfig;

use strict;
use warnings;

use vars qw( $config );

$config = {

    'email_notify_list' => [
        'Konstantin.Bakunov@gmail.com',
    ],

    'max_waited_sessions' => 10,
    'max_blocking_sessions' => 5,
    'db_link_check_timeout' => 15,                          # timeout для проверки доступности dblink'а
    'mailer_repeat_period' => 15,                           # период запуска процесса доставки сообщений из очереди на email
    'job_expire_time' => 60 * 30,                           # 'время жизни' задания в очереди
    'smtp_host' => 'mail.les.loc',                          # SMTP-хост для доставки сообщений
    'email_from' => 'Konstantin.Bakunov@gmail.com',
    'tmpl_path' => './tmpl',

    'databases' => {

        'DB1@link1' => {
            'db_name' => 'dbi:Oracle:DB1',
            'schema' => 'db1',
            'ORACLE_HOME' => '/usr/lib/oracle/11.2/client64',
            'password' => '***',
            'repeat_period' => 15,
            'jobs' => [
                {  'job' => 111,   'proc_name' => 'test1_auto', 'avg_running_time' => 60, },

            ],
            'db_links' => [
                'CRM_1',
            ]
        },

    },

};

1;


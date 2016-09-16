package DbConfig;

use strict;
use warnings;

use vars qw( $config );

$config = {

    'email_notify_list' => [
        'Konstantin_Bakunov@lp.center.rt.ru',
        'Konstantin_Bakunov@center.rt.ru',
    ],

    'max_waited_sessions' => 10,
    'max_blocking_sessions' => 5,

    'databases' => {

        'GS3CTK_ALL@TUDVL' => {
            'db_name' => 'dbi:Oracle:TUDVL',
            'schema' => 'gs3ctk_all',
            'password' => 'devel',
            'repeat_period' => 3,
            'jobs' => [
                {
                    'job' => 1111111,
                    'proc_name' => '',
                    'avg_running_time' => 60,
                }
            ],
            'db_links' => [
                'CRM',
            ]
        },

        'GS_API@TUDVL' => {
            'db_name' => 'dbi:Oracle:TUDVL',
            'schema' => 'gs_api',
            'password' => 'devel',
            'repeat_period' => 3,
        },

        'TU_START_CTK@TUDVL' => {
            'db_name' => 'dbi:Oracle:TUDVL',
            'schema' => 'tu_start$_ctk',
            'password' => 'devel',
            'repeat_period' => 3,
            'jobs' => [
                {
                    'job' => 1111111,
                    'proc_name' => '',
                    'avg_running_time' => 60,
                }
            ],
            'db_links' => [
                'CTAPT',
                'CTAPT_LP',
                'CTAPT_VV',
                'CTAPT_BR',
                'CTAPT_SM',
            ]
        },
    },

};


1;

=cut

1.       Джоб не запущен по расписанию (NEXT_DATE меньше sysdate и THIS_DATE не заполнен)
2.       Джоб не завершил корректно работу, вероятно возникновение exception (по lks_job_log есть не закрытые записи, и при этом джоб не выполняется в момент проверки)
3.       Джоб выполняется нетипично долго (подумать как оценить «типичную» длительность выполнения, вероятно по lks_job_log)
4.       Множество активных сессий с длительным ожиданием выполнения (WAITED условно больше 10)
5.       Множество активных сессий с блокирующей сессией (более 5 сессий блокируются какой-то одной сессией)
6.       Недоступность dblink АСР Старт филиала из схемы tu_start$_ctk

=cut


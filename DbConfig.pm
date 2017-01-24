package DbConfig;

use strict;
use warnings;

use vars qw( $config );

$config = {

    'email_notify_list' => [
        'Konstantin_Bakunov@center.rt.ru',
        #- 'Evgeniy_Vasnev@center.rt.ru',
    ],

    'max_waited_sessions' => 10,
    'max_blocking_sessions' => 5,
    'db_link_check_timeout' => 15,                          # timeout для проверки доступности dblink'а
    'mailer_repeat_period' => 15,                           # период запуска процесса доставки сообщений из очереди на email
    'job_expire_time' => 60 * 30,                           # 'время жизни' задания в очереди
    'smtp_host' => 'mail.les.loc',                          # SMTP-хост для доставки сообщений
    'email_from' => 'Konstantin_Bakunov@lp.center.rt.ru',
    'tmpl_path' => './tmpl',

    'databases' => {

        'GS3CTK_ALL@TU' => {
            'db_name' => 'dbi:Oracle:TU',
            'schema' => 'gs3ctk_all',
            'ORACLE_HOME' => '/usr/lib/oracle/11.2/client64',
            'password' => 'ctk',
            'repeat_period' => 15,
            'jobs' => [
                {  'job' => 62,   'proc_name' => 'ord_run_auto', 'avg_running_time' => 60, },
                {  'job' => 741,  'proc_name' => 'start_update_street', 'avg_running_time' => 60, },
                {  'job' => 761,  'proc_name' => 'dto_invproj_prepare', 'avg_running_time' => 60, },
                {  'job' => 781,  'proc_name' => 'nrptatu_clear_shpd_tab', 'avg_running_time' => 60, },
                {  'job' => 821,  'proc_name' => 'ats_measure_abnerr', 'avg_running_time' => 60, },
                {  'job' => 881,  'proc_name' => 'crm_get_extitem', 'avg_running_time' => 60, },
                {  'job' => 901,  'proc_name' => 'ats_exec_shpd_104', 'avg_running_time' => 60, },
                {  'job' => 902,  'proc_name' => 'ats_exec_shpd_105', 'avg_running_time' => 60, },
                {  'job' => 921,  'proc_name' => 'API_ADRTV_REZ_HOUSE1', 'avg_running_time' => 60, },
                {  'job' => 981,  'proc_name' => 'NRPTATU_MONT_EMK_TECH_MRF', 'avg_running_time' => 60, },
                {  'job' => 1021, 'proc_name' => 'CBR_PR_ERRLISTOO_PROCESSING', 'avg_running_time' => 60, },
                {  'job' => 1061, 'proc_name' => 'CBR_DO_AUTO_DISP_ALL', 'avg_running_time' => 60, },
                {  'job' => 1101, 'proc_name' => 'ats_exec_cmd', 'avg_running_time' => 60, },
                {  'job' => 1122, 'proc_name' => 'cbr_out_fill_cases', 'avg_running_time' => 60, },
                {  'job' => 1124, 'proc_name' => 'cbr_out_fill_queries', 'avg_running_time' => 60, },
                {  'job' => 1142, 'proc_name' => 'fill_ideal_filial', 'avg_running_time' => 60, },
                {  'job' => 1181, 'proc_name' => 'NRPTATU_ETH_SHPD_ALL_FUN', 'avg_running_time' => 60, },
                {  'job' => 1221, 'proc_name' => 'CBR_PR_CRM_SETOUTCLOSEDALL', 'avg_running_time' => 60, },
                {  'job' => 1261, 'proc_name' => 'FILL_DEVICE_LIST', 'avg_running_time' => 60, },
                {  'job' => 1281, 'proc_name' => 'cbr_out_fill_group_problems', 'avg_running_time' => 60, },
                {  'job' => 1341, 'proc_name' => 'cbr_out_fill_orders', 'avg_running_time' => 60, },
                {  'job' => 1361, 'proc_name' => 'NRPTATU_ETH_PORT_SOST_PROC', 'avg_running_time' => 60, },
                {  'job' => 1421, 'proc_name' => 'ats_exec_shpd_103', 'avg_running_time' => 60, },
                {  'job' => 1441, 'proc_name' => 'API_ADRTV_REZ_HOUSE2', 'avg_running_time' => 60, },
                {  'job' => 1442, 'proc_name' => 'API_ADRTV_REZ_HOUSE3', 'avg_running_time' => 60, },
                {  'job' => 1443, 'proc_name' => 'API_ADRTV_REZ_HOUSE4', 'avg_running_time' => 60, },
                {  'job' => 1444, 'proc_name' => 'API_ADRTV_REZ_HOUSE5', 'avg_running_time' => 60, },
                {  'job' => 1445, 'proc_name' => 'API_ADRTV_REZ_HOUSE6', 'avg_running_time' => 60, },
                {  'job' => 1501, 'proc_name' => 'cbr_fill_town_info', 'avg_running_time' => 60, },
                {  'job' => 1521, 'proc_name' => 'ats_exec_subs', 'avg_running_time' => 60, },
                {  'job' => 1601, 'proc_name' => 'crm_get_extitem', 'avg_running_time' => 60, },
                {  'job' => 1602, 'proc_name' => 'crm_get_extitem_bron', 'avg_running_time' => 60, },
                {  'job' => 1401, 'proc_name' => 'gpon_activate_op.process_documents', 'avg_running_time' => 5, },

            ],
            'db_links' => [
                'CRM_STOCK',
            ]
        },

        'GS_API@TU' => {
            'db_name' => 'dbi:Oracle:TU',
            'schema' => 'gs_api',
            'ORACLE_HOME' => '/usr/lib/oracle/11.2/client64',
            'password' => 'gsapi',
            'repeat_period' => 15,
        },

        'TU_START_CTK@TU' => {
            'db_name' => 'dbi:Oracle:TU',
            'schema' => 'tu_start$_ctk',
            'ORACLE_HOME' => '/usr/lib/oracle/11.2/client64',
            'password' => 'tu_start',
            'repeat_period' => 15,
            'jobs' => [
                {   'job' => 41, 'proc_name' => 'docview.copy_data_lp', 'avg_running_time' => 60,  },
                {   'job' => 701, 'proc_name' => 'docview.copy_data_tm', 'avg_running_time' => 60,  },
                {   'job' => 2041, 'proc_name' => 'load_data.update_tu_tables', 'avg_running_time' => 60,  },
                {   'job' => 2443, 'proc_name' => 'docview.copy_data_vr', 'avg_running_time' => 60,  },
                {   'job' => 2444, 'proc_name' => 'docview.copy_data_sm', 'avg_running_time' => 60,  },
                {   'job' => 2445, 'proc_name' => 'docview.copy_data_kl', 'avg_running_time' => 60,  },
                {   'job' => 2462, 'proc_name' => 'docview.copy_data_vl', 'avg_running_time' => 60,  },
                {   'job' => 2482, 'proc_name' => 'docview.copy_data_vv', 'avg_running_time' => 60,  },
                {   'job' => 2483, 'proc_name' => 'docview.copy_data_br', 'avg_running_time' => 60,  },
                {   'job' => 2621, 'proc_name' => 'docview.copy_data_wfm_12', 'avg_running_time' => 60,  },
                {   'job' => 2623, 'proc_name' => 'docview.copy_data_iv', 'avg_running_time' => 60,  },
                {   'job' => 2624, 'proc_name' => 'docview.copy_data_ks', 'avg_running_time' => 60,  },
                {   'job' => 2681, 'proc_name' => 'docview.copy_data_wfm_6', 'avg_running_time' => 60,  },
                {   'job' => 2682, 'proc_name' => 'docview.copy_data_wfm_2', 'avg_running_time' => 60,  },
                {   'job' => 2701, 'proc_name' => 'docview.copy_data_wfm_9', 'avg_running_time' => 60,  },
                {   'job' => 2702, 'proc_name' => 'docview.copy_data_wfm_5', 'avg_running_time' => 60,  },
                {   'job' => , 'proc_name' => '', 'avg_running_time' => 60,  },
                {   'job' => , 'proc_name' => '', 'avg_running_time' => 60,  },
                {   'job' => , 'proc_name' => '', 'avg_running_time' => 60,  },
                {   'job' => , 'proc_name' => '', 'avg_running_time' => 60,  },
                {   'job' => , 'proc_name' => '', 'avg_running_time' => 60,  },
                {   'job' => , 'proc_name' => '', 'avg_running_time' => 60,  },
                {   'job' => , 'proc_name' => '', 'avg_running_time' => 60,  },
                {   'job' => , 'proc_name' => '', 'avg_running_time' => 60,  },
                {   'job' => , 'proc_name' => '', 'avg_running_time' => 60,  },
            ],
            'db_links' => [
                'CTAPT',
                'CTAPT_LP',
                'CTAPT_VV',
                'CTAPT_BR',
                'CTAPT_SM',
                'CTAPT_OL',
                'CTAPT_KL',
                'CTAPT_BL',
                'CTAPT_VL',
                'CTAPT_TL',
                'CTAPT_TV',
                'CTAPT_MF',
                'CTAPT_KR',
                'CTAPT_RZ',
                'CTAPT_VR',
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


  select  jr.SID, jr.FAILURES, jr.LAST_DATE, jl.date_beg, jr.JOB, jl.name_proc, jj.what
    from  dba_jobs_running  jr  join user_jobs jj  on  jj.JOB = jr.JOB
    join  lks_job_log  jl  on  jj.what  like  '%' || jl.name_proc || '%'
     and  jl.date_end is null



1.       Сократить заголовок письма до шаблона «СХЕМА@БД -> НАЗВАНИЕ_ОБЪЕКТА_НАБЛЮДЕНИЯ»
             Где НАЗВАНИЕ_ОБЪЕКТА_НАБЛЮДЕНИЯ = (JOBS, DB_LINK, SESSION и т.п.)
2.       Для события BROKEN в письме писать для каждого джоба (таблицей): id, SYSDATE, LAST_DATE, FAILURES
3.       Для события «не запущен» в письме писать: id, SYSDATE, LAST_DATE, NEXT_DATE, FAILURES


=cut


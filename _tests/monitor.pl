#! /usr/bin/perl
#-----------------------------------------------------------------------------------------------

use strict;
use warnings;

use DBI;
use Date::Calc;
use Time::Local;


$ENV{ORACLE_HOME} = "/usr/lib/oracle/11.2/client64";
$ENV{NLS_LANG} = "AMERICAN_AMERICA.AL32UTF8";
#$ENV{NLS_LANG} = "american_america.CL8MSWIN1251";
$ENV{NLS_DATE_FORMAT} = 'YYYY-Mm-DD HH24:MI:SS';

my $dbh = DBI->connect( 'dbi:Oracle:tu', 'gs3ctk_all', 'ctk',  { PrintError => 1, RaiseError => 1, AutoCommit => 0, } );


my $sth = $dbh->prepare( "    SELECT  job  FROM  user_jobs  WHERE  BROKEN = 'Y' " );
$sth->execute;
my @jobs = ();
push(@jobs, $_) while (($_) = $sth->fetchrow_array);
print join('; ', @jobs), "\n";


$sth = $dbh->prepare( "    SELECT  sid, ser, date_beg, name_proc  FROM  lks_job_log  WHERE  date_end  IS NULL  AND  (sysdate - date_beg) > 5 / 24 / 60 " );
$sth->execute;
while (my ($sid, $ser, $date_beg, $name_proc) = $sth->fetchrow_array) {
    print  join('; ', ($sid, $ser, $date_beg, $name_proc)), "\n";
}



$dbh->disconnect;


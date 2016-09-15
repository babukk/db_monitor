package DbConfig;

use strict;
use warnings;

use vars qw( $config );

$config = {

    'DB1' => {
        'db_name' => 'dbi:Oracle:TUDVL',
        'schema' => 'gs3ctk_all',
        'password' => 'devel',
        'repeat_period' => 3,
    },

    'DB2' => {
        'db_name' => 'dbi:Oracle:TUDVL',
        'schema' => 'gs_api',
        'password' => 'devel',
        'repeat_period' => 3,
    },

};


1;

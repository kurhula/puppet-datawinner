class datawinners::postgres ($database_user, $database_name, $user) {
  # ####### Postgres installation ############
  class { "postgresql::server":
    config_hash => {
      'listen_addresses'           => '*',
      'postgres_password'          => 'postgres',
      'ip_mask_allow_all_users'    => '0.0.0.0/0',
      'ip_mask_deny_postgres_user' => '0.0.0.0/32',
    }
    ,
  }

  $pg_conf_include_file = "${postgresql::params::confdir}/postgresql_puppet_extras.conf"

  file { $pg_conf_include_file:
    content => 'standard_conforming_strings = off',
    notify  => Service['postgresql'],
  }

  postgresql::database_user { "${database_user}":
    createdb      => true,
    superuser     => true,
    password_hash => postgresql_password("${database_user}", "${database_user}"),
    require       => File["$pg_conf_include_file"],
  }

  postgresql::database_user { "${user}":
    createdb      => true,
    superuser     => true,
    password_hash => postgresql_password("${user}", "${user}"),
    require       => File["$pg_conf_include_file"],
  }

  postgresql::database { "${database_name}":
    owner   => "${database_user}",
    charset => 'utf8',
    require => Postgresql::Database_user["${database_user}"],
  }
}
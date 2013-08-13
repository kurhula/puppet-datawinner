node base_system {
  package { 'git-core': ensure => installed, }

  package { 'curl': ensure => installed }

  group { "datawinners": ensure => "present", }

  user { "datawinners":
    ensure     => "present",
    managehome => true,
    gid        => "datawinners",
    require    => Group["datawinners"],
    shell      => "/bin/bash",
  }

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

  postgresql::database_user { 'datawinners':
    # TODO: ensure is not yet supported
    # ensure        => present,
    createdb => true,
    superuser => true,
    db => 'datawinners',
    password_hash => postgresql_password('datawinners', 'datawinners'),
    require       => Class['postgresql::server'],
  }

  $pg_conf_include_file = "${postgresql::params::confdir}/postgresql_puppet_extras.conf"

  file { $pg_conf_include_file:
    content => 'standard_conforming_strings = off',
    notify  => Service['postgresql'],
  }

  # ############## Apache Couchdb configuration ###########
  # # couchdb user/group is created as part of the installation
  class { "couchdb":
  }

  couchdb::instance { "couchdbmain":
    require      => Class['couchdb'],
    service_name => "couchdbmain",
    database_dir => "/opt/apache-couchdb/var/lib/couchdbmain",
  }

  couchdb::instance { "couchdbfeed":
    require      => Class['couchdb'],
    service_name => "couchdbfeed",
    database_dir => "/opt/apache-couchdb/var/lib/couchdbfeed",
    port         => "7984",
  }
 
  #  class {"tomcat":
  #  }

  #
  # node dev inherits base_system{
  #  class{"datawinnersapp":}
  #
  #}
  #
  # node ci inherits dev {
  #  class { 'jenkins': }
  #
  #  jenkins::plugin {
  #    'git' : ;
  #  }

  $home_dir = "/home/datawinners"

  file { "${home_dir}": ensure => directory, owner=> 'datawinners', group => 'datawinners', recurse=> true}

  vcsrepo { "${home_dir}/workspace/datawinners":
    ensure   => present,
    provider => git,
    source   => 'git://github.com/mangroveorg/datawinners.git',
  }

  vcsrepo { "${home_dir}/workspace/mangrove":
    ensure   => present,
    provider => git,
    source   => 'git://github.com/mangroveorg/mangrove.git',
  }

  # ###### Python installation ############

  exec { "update-apt-get":
    command => "apt-get update",
    path    => ['/usr/local/bin', '/usr/bin', '/bin'],
    user    => root,
  }

  class { 'python':
    virtualenv => true,
    dev        => true,
    pip        => true,
    require    => Exec["update-apt-get"],
  }

  python::virtualenv { "${home_dir}/virtual_env/datawinners":
    ensure  => present,
    owner   => "root",
    group   => "root",
    require => Class['python'],
  }

  package{"nginx":
    ensure => present,
  }

  python::pip { "pip":
    virtualenv => "${home_dir}/virtual_env/datawinners",
    owner      => 'root',
    require    => User["datawinners"],
  }
        file { "/home/datawinners/workspace":
          recurse => true,
          owner => 'datawinners',
          group => 'datawinners',
          require => [Vcsrepo ['/home/datawinners/workspace/mangrove'], Vcsrepo ['/home/datawinners/workspace/datawinners']],

        }

        package{"postgresql-server-dev-9.1":
          ensure => present,
        }

        package{"libxslt1-dev":
          ensure => present
        }

        package{"libxml2-dev":
          ensure => present
        }
        package{"postgresql-9.1-postgis":
          ensure => present,
        }

        python::requirements { '/home/datawinners/workspace/datawinners/requirements.pip':
          virtualenv => '/home/datawinners/virtual_env/datawinners',
          owner      => 'datawinners',
          group      => 'datawinners',
          require    => [File["/home/datawinners/workspace"], Python::Requirements['/home/datawinners/workspace/mangrove/requirements.pip']],
        }

        python::requirements { '/home/datawinners/workspace/mangrove/requirements.pip':
          virtualenv => '/home/datawinners/virtual_env/datawinners',
          owner      => 'datawinners',
          group      => 'datawinners',
          require    => [File["/home/datawinners/workspace"],Package['postgresql-server-dev-9.1'], Package['libxml2-dev']],
        }
  #  python::requirements { "${home_dir}/workspace/datawinners/requirements.pip":
  #    virtualenv => "${home_dir}/virtual_env/datawinner",
  #    owner      => 'root',
  #    group      => 'root',
  #  }

}

node default inherits base_system {
}

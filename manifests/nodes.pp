node base_system {
  package { 'git-core': ensure => installed, }

  package { 'curl': ensure => installed }

  group { "datawinners": ensure => "present", }

  user { "datawinners":
    ensure     => "present",
    managehome => true,
    gid        => "datawinners",
    require    => Group["datawinners"],
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

  postgresql::database_user { 'mangrove':
    # TODO: ensure is not yet supported
    # ensure        => present,
    password_hash => postgresql_password('mangrove', 'mangrove'),
    require       => Class['postgresql::server'],
  }

  $pg_conf_include_file = "${postgresql::params::confdir}/postgresql_puppet_extras.conf"

  file { $pg_conf_include_file:
    content => 'standard_conforming_strings = off',
    notify  => Service['postgresql'],
  }

  # ############## Apache Couchdb configuration ###########
  # # couchdb user/group is created as part of the installation


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
}

node default {
  group { "datawinners": ensure => "present", }

  user { "datawinners":
    ensure     => "present",
    managehome => true,
    gid        => "datawinners",
    require    => Group["datawinners"],
  }
  $home_dir = "/home/datawinners"

  class { "couchdb": }

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

  vcsrepo { '${home_dir}/workspace/datawinners':
    ensure   => present,
    provider => git,
    source   => 'git://github.com/mangroveorg/datawinners.git',
  }

  vcsrepo { '${home_dir}/workspace/mangrove':
    ensure   => present,
    provider => git,
    source   => 'git://github.com/mangroveorg/mangrove.git',
  }

  # ####### Python installation ############
  class { 'python':
    virtualenv => true
  }

  python::virtualenv { '${home_dir}/virtual_env/datawinner':
    ensure => present,
    owner  => "datawinners",
    group  => "datawinners",
  }

  python::pip { "pip":
    virtualenv => '${home_dir}/virtual_env/datawinner',
    owner      => 'datawinners',
    require    => User["datawinners"],
  }

  python::requirements { '${home_dir}/workspace/datawinners/requirements.pip':
    virtualenv => '${home_dir}/virtual_env/datawinner',
    owner      => 'datawinners',
    group      => 'datawinners',
  }

  class { "uwsgi":
  }

  uwsgi::application { }

}
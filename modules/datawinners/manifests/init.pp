
class datawinners ($user = 'datawinners', $group = 'datawinners', $database_name = 'geodjango') {
  group { "${group}": ensure => "present", }

  user { "${user}":
    ensure     => "present",
    managehome => true,
    gid        => "${group}",
    require    => Group["${group}"],
    shell      => "/bin/bash",
  }
  $home_dir = "/home/${user}"

  class { "datawinners::couchdb": }

  class { "datawinners::postgres":
    user          => "${user}",
    database_name => "${database_name}",
  }

  class { "datawinners::uwsgi_configure":
    user  => "${user}",
    group => "${group}",
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
    owner   => "${user}",
    group   => "${group}",
    require => Class['python'],
  }

  python::pip { "pip":
    virtualenv => "${home_dir}/virtual_env/datawinners",
    owner      => "${user}",
    require    => User["${user}"],
  }

  # ################## Datawinners app repositories ####################


  file { "${home_dir}":
    ensure  => directory,
    owner   => "${user}",
    group   => "${group}",
    recurse => true,
    require => User["${user}"],
  }

  vcsrepo { "${home_dir}/workspace/datawinners":
    ensure   => present,
    provider => git,
    source   => 'git://github.com/mangroveorg/datawinners.git',
    require  => File["${home_dir}"],
  }

  vcsrepo { "${home_dir}/workspace/mangrove":
    ensure   => present,
    provider => git,
    source   => 'git://github.com/mangroveorg/mangrove.git',
    require  => File["${home_dir}"],
  }

  file { "${home_dir}/workspace":
    recurse => true,
    owner   => "${user}",
    group   => "${group}",
    require => [Vcsrepo["${home_dir}/workspace/mangrove"], Vcsrepo["${home_dir}/workspace/datawinners"]],
  }

  package { "postgresql-server-dev-9.1": ensure => present, }

  package { "libxslt1-dev": ensure => present }

  package { "libxml2-dev": ensure => present }

  package { "postgresql-9.1-postgis": ensure => present, }

  python::requirements { "${home_dir}/workspace/datawinners/requirements.pip":
    virtualenv => "${home_dir}/virtual_env/datawinners",
    owner      => "${user}",
    group      => "${group}",
    require    => [File["${home_dir}/workspace"], Python::Requirements["${home_dir}/workspace/mangrove/requirements.pip"]],
  }

  python::requirements { "${home_dir}/workspace/mangrove/requirements.pip":
    virtualenv => "${home_dir}/virtual_env/datawinners",
    owner      => "${user}",
    group      => "${group}",
    require    => [File["${home_dir}/workspace"], Package['postgresql-server-dev-9.1'], Package['libxml2-dev']],
  }

  class { "datawinners::nginx":
    home_dir => "${home_dir}",
  }
}

class datawinners ($user = 'datawinners', $group = 'datawinners', $database_name = 'mangrove') {
  group { "${group}": ensure => "present", }

  user { "${user}":
    ensure     => "present",
    managehome => true,
    gid        => "${group}",
    require    => Group["${group}"],
    shell      => "/bin/bash",
  }
  $home_dir = "/home/${user}"

  exec {"check_couchdb":
  command => '/bin/true',
  onlyif => '/usr/bin/test -e /etc/init.d/couchdbmain',
  }
  class { "datawinners::couchdb":
    require => Exec["check_couchdb"],
  }

  class { "datawinners::postgres":
    user          => "${user}",
    database_name => "${database_name}",
  }

  class { "datawinners::uwsgi_configure":
    user  => "${user}",
    group => "${group}",
  }

  class { "datawinners::python":
    user  => $user,
    group => $group,
  }
  
  class {"datawinners::tomcat":
    user => $user,
    group => $group,
    url => "http://www.us.apache.org/dist/tomcat/tomcat-7/v7.0.42/bin/apache-tomcat-7.0.42.tar.gz",
  }
  
  class {"datawinners::elasticsearch":}

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
    require    => [
      File["${home_dir}/workspace"],
      Package['postgresql-server-dev-9.1'],
      Package['libxml2-dev'],
      Class["datawinners::python"]],
  }

  exec { "initialize-datawinners-environment":
    command => "${home_dir}/workspace/datawinners/init_ubuntu_12.04.sh",
    user => $user,
    require => [Python::Requirements["${home_dir}/workspace/datawinners/requirements.pip"] , Class["datawinners::postgres"]],
  }

  class { "datawinners::nginx":
    home_dir => "${home_dir}",
  }
}
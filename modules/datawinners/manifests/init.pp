
class datawinners ($user = 'mangrover', $group = 'mangrover', $database_name = 'mangrove') {
  group { "${group}": ensure => "present", }

  user { "${user}":
    ensure     => "present",
    managehome => true,
    gid        => "${group}",
    require    => Group["${group}"],
    shell      => "/bin/bash",
  }->
  file { "/var/log/datawinners":
    ensure => directory,
    owner  => "${user}",
    group  => "${group}",
    mode   => "777",
  } 
  $home_dir = "/home/${user}"

  exec { "java_installed": command => "/usr/bin/which java" }

  exec { "check_couchdb":
    command => '/bin/true',
    onlyif  => '/usr/bin/test -e /etc/init.d/couchdbmain',
  }

  class { "datawinners::couchdb":
    require => Exec["check_couchdb"],
  }

  class { "datawinners::postgres":
    database_user => "${user}",
    database_name => "${database_name}",
  }

  class { "datawinners::uwsgi_configure":
    user  => "${user}",
    group => "${group}",
    require => File["/var/log/datawinners"],
  }

  class { "datawinners::python":
    user  => $user,
    group => $group,
  }

  class { "datawinners::tomcat":
    user    => $user,
    group   => $group,
    url     => "http://www.us.apache.org/dist/tomcat/tomcat-7/v7.0.42/bin/apache-tomcat-7.0.42.tar.gz",
    require => Exec["java_installed"],
  }

  class { "datawinners::elasticsearch":
    url     => "https://download.elasticsearch.org/elasticsearch/elasticsearch/elasticsearch-0.90.3.deb",
    require => Exec["java_installed"],
  }

  # ################## Datawinners app repositories ####################


  file { "${home_dir}":
    ensure  => directory,
    owner   => "${user}",
    group   => "${group}",
    require => User["${user}"],
  }

  vcsrepo { "${home_dir}/workspace/datawinners":
    ensure   => present,
    provider => git,
    source   => 'git://github.com/mangroveorg/datawinners.git',
    owner    => "${user}",
    group    => "${group}",
    require  => File["${home_dir}"],
  }

  vcsrepo { "${home_dir}/workspace/mangrove":
    ensure   => present,
    provider => git,
    source   => 'git://github.com/mangroveorg/mangrove.git',
    owner    => "${user}",
    group    => "${group}",
    require  => File["${home_dir}"],
  }
  
  exec{"workspace_ownership":
    command => "/bin/chown -R ${user}:${group} ${home_dir}/workspace",
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
    require    => [Exec["workspace_ownership"], Python::Requirements["${home_dir}/workspace/mangrove/requirements.pip"]],
  }

  python::requirements { "${home_dir}/workspace/mangrove/requirements.pip":
    virtualenv => "${home_dir}/virtual_env/datawinners",
    owner      => "${user}",
    group      => "${group}",
    require    => [
      Exec["workspace_ownership"],
      Package['postgresql-server-dev-9.1'],
      Package['libxml2-dev'],
      Class["datawinners::python"]],
  }

  exec { "initialize-datawinners-environment":
    command => "${home_dir}/workspace/datawinners/init_ubuntu_12.04.sh",
    user      => $user,
    logoutput => "on_failure",
    require   => [Python::Requirements["${home_dir}/workspace/datawinners/requirements.pip"], Class["datawinners::postgres"]],
  }

  file { "/home/${user}/google": ensure => directory }

  file { "${home_dir}/google/google3756418eb1f4bb6c.html":
    content => "google3756418eb1f4bb6c.html",
    owner   => "nginx",
    group   => "nginx",
    mode    => 0666,
  }
  class { "datawinners::nginx":
    home_dir         => "${home_dir}",
    package_location => 'http://nginx.org/download/nginx-1.2.9.tar.gz',
    package_name     => 'nginx-1.2.9'
  }
}
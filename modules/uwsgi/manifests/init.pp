class uwsgi ($package_location = "http://projects.unbit.it/downloads/uwsgi-1.4.9.tar.gz", $file_name = "uwsgi-1.4.9",) {
  group { "uwsgi": ensure => "present", }

  user { "uwsgi":
    ensure     => present,
    gid        => "uwsgi",
    managehome => false,
    shell      => '/bin/sh',
    require    => Group["uwsgi"],
  }

  # lts for uwsgi-1.4.9 is till 2014 for regular customers and till 2015 for paid customers
  exec { 'download_uwsgi':
    cwd     => '/opt/',
    path    => ['/usr/local/bin', '/usr/bin', '/bin'],
    command => "wget -q ${package_location} -O ${file_name}.tar.gz",
    timeout => 120,
  }

  exec { 'extract':
    cwd     => '/opt/',
    command => "/bin/tar -xzvf ${file_name}.tar.gz",
    timeout => '120',
    require => Exec["download_uwsgi"],
  }

  file { "/opt/${file_name}":
    mode    => '0777',
    recurse => true,
    require => Exec['extract'],
    owner   => 'datawinners',
    group   => 'datawinners',
  }

  package { 'build-essential':
    ensure => present,
  }

  exec { "build_uwsgi":
    cwd     => "/opt/${file_name}",
    path    => ['/usr/local/bin', '/usr/bin', '/bin'],
    command => "python uwsgiconfig.py --build",
    require => [File["/opt/${file_name}"], Package['build-essential']],
    user    => 'datawinners',
  }

  file { '/usr/bin/uwsgi':
    ensure  => 'present',
    source  => '/opt/${file_name}',
    owner   => "root",
    group   => "root",
    mode    => "0755",
    require => [User["uwsgi"], Exec["build_uwsgi"]],
  }

  file { '/var/log/uwsgi':
    ensure => 'directory',
    owner  => 'uwsgi',
    group  => 'uwsgi',
    mode   => "0755",
  }

}

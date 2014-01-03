class datawinners::memcached ($owner, $group) {

  puppi::netinstall { "libevent":
    path                => '/usr/local/bin:/bin:/sbin:/usr/bin:/usr/sbin',
    url                 => "https://github.com/downloads/libevent/libevent/libevent-2.0.21-stable.tar.gz",
    destination_dir     => "/var/tmp",
    owner   => "${owner}",
    group   => "${group}",
    postextract_command => "/bin/sh -c \"cd /var/tmp/libevent-2.0.21-stable && ./configure && make && sudo make install\""
  }->

  puppi::netinstall { "memcached":
    path                => '/usr/local/bin:/bin:/sbin:/usr/bin:/usr/sbin',
    url                 => "http://www.memcached.org/files/memcached-1.4.17.tar.gz",
    destination_dir     => "/var/tmp",
    owner   => "${owner}",
    group   => "${group}",
    postextract_command => "/bin/sh -c \"cd /var/tmp/memcached-1.4.17 && ./configure && make && sudo make install\""
  }->

  puppi::netinstall { "libmemcached":
    path                => '/usr/local/bin:/bin:/sbin:/usr/bin:/usr/sbin',
    url                 => "https://launchpad.net/libmemcached/1.0/1.0.17/+download/libmemcached-1.0.17.tar.gz",
    destination_dir     => "/var/tmp",
    owner   => "${owner}",
    group   => "${group}",
    postextract_command => "/bin/sh -c \"cd /var/tmp/libmemcached-1.0.17 && ./configure --prefix=/usr && make && sudo make install\"",
    require             => Package["libcloog-ppl0"],
  }->

  file { "/etc/init.d/memcached":
    ensure  => present,
    content => template("datawinners/etc/init.d/memcached.erb"),
    owner  => "${owner}",
    group  => "${group}",
    mode    => '755',
  } ->

  file { "/etc/default/start-memcached":
    ensure  => present,
    content => template("datawinners/memcached/start-memcached.erb"),
    owner  => "${owner}",
    group  => "${group}",
    mode    => '755',
  } ->

  file { "/etc/default/memcached":
    ensure  => present,
    content => template("datawinners/etc/default/memcached.erb"),
    owner  => "${owner}",
    group  => "${group}",
    mode    => '755',
  } ->

  service { 'memcached':
    ensure => 'running',
    enable => true,
  }

  package { "libcloog-ppl0":
    ensure => 'present'
  }

}
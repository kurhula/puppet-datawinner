class datawinners::nginx (
  $home_dir,
  $package_location = 'http://nginx.org/download/nginx-1.2.9.tar.gz',
  $env              = "dev",
  $package_name     = 'nginx-1.2.9') {
  $required_packages = ['libpcre3-dev', 'zlib1g-dev']

  package { $required_packages: ensure => 'installed', }
  group { "nginx": ensure => present } ->
  user { "nginx":
    ensure     => "present",
    gid        => 'nginx',
    managehome => false,
    system     => true,
  } ->
  puppi::netinstall { "nginx":
    url                 => "${package_location}",
    destination_dir     => "/opt/",
    owner               => "nginx",
    group               => "nginx",
    postextract_command => "./configure --prefix=/opt/${package_name} --user=nginx  --group=nginx --sbin-path=/usr/local/sbin --conf-path=/opt/${package_name}/conf/nginx.conf  --pid-path=/opt/${package_name}/nginx.pid --with-http_gzip_static_module  --with-http_ssl_module  ; make ; make install",
    require             => Package[$required_packages],
  } ->
  file { "/opt/${package_name}/conf.d":
    ensure => directory,
    owner  => 'nginx',
    group  => 'nginx',
    mode   => '755',
  } ->
  file { "/opt/${package_name}/conf.d/datawinner.conf":
    owner   => "nginx",
    group   => "nginx",
    mode    => '755',
    content => template("datawinners/etc/nginx/conf.d/${env}.datawinner.conf.erb"),
  } ->
  file { "/opt/${package_name}/conf/nginx.conf":
    owner  => "nginx",
    group  => "nginx",
    mode   => '755',
    source => "puppet:///modules/datawinners/etc/nginx/nginx.conf",
  } ->
  file { "/opt/${package_name}/conf.d/datawinners.ssl.conf":
    owner   => "nginx",
    group   => "nginx",
    mode    => '755',
    content => template("datawinners/etc/nginx/conf.d/${env}.datawinners.ssl.conf.erb"),
  }

  file { "/var/log/nginx":
    ensure => directory,
    owner  => "nginx",
    group  => "nginx",
    mode   => '755',
  }

  file { "${home_dir}/certificates":
    ensure => directory,
    owner  => "nginx",
    group  => "nginx",
    mode   => '755',
  }

  file { "${home_dir}/certificates/datawinners_chained.crt":
    owner   => "nginx",
    group   => "nginx",
    mode    => '440',
    source  => "puppet:///modules/datawinners/certificates/datawinners_chained.crt",
    require => File["${home_dir}/certificates"],
  }

  file { "${home_dir}/certificates/server.key":
    owner   => "nginx",
    group   => "nginx",
    mode    => '440',
    source  => "puppet:///modules/datawinners/certificates/server.key",
    require => File["${home_dir}/certificates"],
  }

}
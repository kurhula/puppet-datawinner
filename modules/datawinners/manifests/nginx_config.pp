class datawinners::nginx_config ($home_dir, $package_location, $package_name) {
  $required_packages = ['build-essential', 'libpcre3-dev', 'zlib1g-dev']

  if $hostname =~ /dwprod/ {
    $domain_name = "www.datawinners.com"
  } else {
    $domain_name = "localhost"
  }
  notice("Using domain name  $domain_name")
  
  package { $required_packages: ensure => 'present', }
  group { "nginx": ensure => present } ->
  user { "nginx":
    ensure     => "present",
    gid        => 'nginx',
    managehome => false,
    system     => true,
  } ->
  puppi::netinstall { "nginx":
    path                => '/usr/local/bin:/bin:/sbin:/usr/bin:/usr/sbin',
    url                 => "${package_location}",
    destination_dir     => "/var/tmp",
    owner               => "nginx",
    group               => "nginx",
    postextract_command => "/bin/sh -c \"cd /var/tmp/${package_name} && ./configure --prefix=/opt/${package_name} --user=nginx  --group=nginx --sbin-path=/usr/local/sbin --conf-path=/opt/${package_name}/conf/nginx.conf  --pid-path=/opt/${package_name}/logs/nginx.pid --with-http_gzip_static_module  --with-http_ssl_module  && make && make install\"",
    require             => Package[$required_packages],
  } ->
  file { "/opt/${package_name}/conf/nginx.conf":
    content => template("datawinners/opt/nginx.conf.erb"),
    mode    => '755',
    owner   => 'nginx',
    group   => 'nginx',
    ensure  => present
  } ->
  file { "/etc/init.d/nginx":
    ensure  => present,
    content => template("datawinners/etc/init.d/nginx.erb"),
    owner   => 'nginx',
    group   => 'nginx',
    mode    => '755',
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
    content => template("datawinners/etc/nginx/conf.d/datawinner.conf.erb"),
  } ->
  file { "/opt/${package_name}/conf.d/datawinners.ssl.conf":
    owner   => "nginx",
    group   => "nginx",
    mode    => '755',
    content => template("datawinners/etc/nginx/conf.d/datawinners.ssl.conf.erb"),
  } ->
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

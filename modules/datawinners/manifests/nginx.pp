class datawinners::nginx ($env = "dev", $home_dir, $user, $group) {
  package { "nginx": ensure => present, }

  file { "/etc/nginx/conf.d/datawinner.conf":
    owner   => "${user}",
    group   => "${group}",
    mode    => '755',
    content => template("datawinners/etc/nginx/conf.d/${env}.datawinner.conf.erb"),
    require => Package["nginx"],
  }

  file { "/etc/nginx/conf.d/datawinners.ssl.conf":
    owner   => "${user}",
    group   => "${group}",
    mode    => '755',
    content => template("datawinners/etc/nginx/conf.d/${env}.datawinners.ssl.conf.erb"),
    require => Package["nginx"],
  }

  file { "/var/log/nginx":
    ensure => directory,
    owner  => "${user}",
    group  => "${group}",
    mode   => '755',
  }

  file { "${home_dir}/certificates":
    ensure => directory,
    owner  => "${user}",
    group  => "${group}",
    mode   => '755',
  }

  file { "${home_dir}/certificates/datawinners_chained.crt":
    owner   => "${user}",
    group   => "${group}",
    mode    => '755',
    source  => "puppet:///modules/datawinners/certificates/datawinners_chained.crt",
    require => File["${home_dir}/certificates"],
  }

  file { "${home_dir}/certificates/server.key":
    owner   => "${user}",
    group   => "${group}",
    mode    => '755',
    source  => "puppet:///modules/datawinners/certificates/server.key",
    require => File["${home_dir}/certificates"],
  }

  file { "/etc/nginx/nginx.conf":
    owner   => "${user}",
    group   => "${group}",
    mode    => '755',
    source  => "puppet:///modules/datawinners/etc/nginx/nginx.conf",
    require => Package["nginx"],
  }
}
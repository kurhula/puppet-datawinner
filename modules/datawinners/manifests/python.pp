
class datawinners::python ($user, $group) {
  $home_dir = "/home/${user}"

  exec { "update-apt-get":
    command => "apt-get update",
    path    => ['/usr/local/bin', '/usr/bin', '/bin'],
    user    => root,
  }

  class { '::python':
    virtualenv => true,
    dev        => true,
    pip        => true,
    require    => Exec["update-apt-get"],
  }

  python::virtualenv { "${home_dir}/virtual_env/datawinners":
    ensure  => present,
    owner   => "${user}",
    group   => "${group}",
    require => Class['::python'],
  }

  python::pip { "pip":
    virtualenv => "${home_dir}/virtual_env/datawinners",
    owner      => "${user}",
    require    => User["${user}"],
  }

  package { "python-gdal":
    ensure  => "present",
    require => Class['::python'],
  }
}
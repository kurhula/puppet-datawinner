class datawinners::uwsgi_configure ($user, $group) {
  file { "/etc/init.d/uwsgi":
    content => template("datawinners/etc/init.d/uwsgi.erb"),
    owner   => 'root',
    group   => 'root',
    mode    => '755',
  } ->
  file { "/etc/default/uwsgi.ini":
    content => template("datawinners/etc/default/uwsgi.ini.erb"),
    owner   => 'root',
    group   => 'root',
    mode    => '644',
  } ->
  file { "/var/log/uwsgi":
    ensure => "directory",
    owner  => "${user}",
    group  => "${group}",
    mode   => "755",
  } ->
  file { "/var/log/datawinners":
    ensure => "directory",
    owner  => "${user}",
    group  => "${group}",
    mode   => "755",
  } ->
  service { 'uwsgi':
    ensure => 'running',
    enable => true,
  }

}
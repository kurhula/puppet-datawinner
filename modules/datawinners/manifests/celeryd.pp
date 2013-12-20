class datawinners::celeryd ($home_dir, $owner, $group) {
  
  file { "/etc/init.d/celeryd":
    ensure  => present,
    content => template("datawinners/etc/init.d/celeryd.erb"),
    owner  => "${owner}",
    group  => "${group}",
    mode    => '755',
  } ->
  file { "/etc/default/celeryd":
    ensure  => present,
    content => template("datawinners/etc/default/celeryd.erb"),
    owner  => "${owner}",
    group  => "${group}",
    mode    => '755',
  } ->
  service { 'celeryd':
    ensure => 'running',
    enable => true,
  }
}
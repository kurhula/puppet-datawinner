class datawinners::remainders_config ($owner, $group) {

  file { "/etc/init.d/remainders":
    ensure  => present,
    content => template("datawinners/etc/init.d/remainders.erb"),
    owner  => "${owner}",
    group  => "${group}",
    mode    => '755',
  }
}
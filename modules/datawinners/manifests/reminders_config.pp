class datawinners::reminders_config ($owner, $group) {

  file { "/etc/init.d/reminders":
    ensure  => present,
    content => template("datawinners/etc/init.d/reminders.erb"),
    owner  => "${owner}",
    group  => "${group}",
    mode    => '755',
  }
}
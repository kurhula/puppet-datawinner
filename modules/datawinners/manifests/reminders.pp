class datawinners::reminders ($owner, $group) {
  class { "datawinners::reminders_config":
    owner => $owner,
    group => $group,
  } ->
  service { 'reminders':
    ensure => 'running',
    enable => true,
  }
}
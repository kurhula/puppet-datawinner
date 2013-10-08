class datawinners::remainders ($owner, $group) {
  class { "datawinners::remainders_config":
    owner => $owner,
    group => $group,
  } ->
  service { 'remainders':
    ensure => 'running',
    enable => true,
  }
}
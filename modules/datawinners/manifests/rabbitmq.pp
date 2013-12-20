class datawinners::rabbitmq ($owner, $group) {
  
  package { "rabbitmq-server":
    ensure => "installed"
  } ->
  service { 'rabbitmq-server':
    ensure => 'running',
    enable => true,
  }
}
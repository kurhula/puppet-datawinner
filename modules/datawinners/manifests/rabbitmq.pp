class datawinners::rabbitmq ($owner, $group) {
  package { "rabbitmq-server": ensure => "installed" } ->
  exec { "install_rabbitmq_management_plugins": command => '/usr/lib/rabbitmq/lib/rabbitmq_server-2.7.1/sbin/rabbitmq-plugins enable rabbitmq_management', 
  } ->
  exec { "restart_rabbitmq_server": command => 'service rabbitmq_server restart' } ->
  service { 'rabbitmq-server':
    ensure => 'running',
    enable => true,
  }
}
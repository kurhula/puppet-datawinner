define uwsgi::application (
  $port        = "9001",
  $working_dir = "/home/datawinners/workspace/datawinners/datawinners",
  $pythonpath  = "/home/datawinners/workspace/datawinners",
  $home        = "/home/datawinners/virtual_env/datawinners",) {
  file { "/etc/default/uwsgi.ini":
    ensure  => 'present',
    content => template("uwsgi/uwsgi.ini.erb"),
    owner   => "uwsgi",
    group   => "uwsgi",
    mode    => "0755",
  }

  file { '/etc/init.d/uwsgi':
    source => "puppet:///modules/uwsgi/etc/init.d/uwsgi",
    mode   => "0755",
    owner  => "root",
    group  => "root",
  }

  #  service { "uwsgi":
  #    ensure     => running,
  #    hasstatus  => true,
  #    hasrestart => true,
  #    enable     => true,
  #    subscribe  => File["/etc/init.d/uwsgi", "/etc/default/uwsgi.ini"],
  #  }
}
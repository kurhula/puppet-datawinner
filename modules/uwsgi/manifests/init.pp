# class uwsgi ($package_location = "http://projects.unbit.it/downloads/uwsgi-1.4.9.tar.gz", $file_name = "uwsgi-1.4.9",) {
class uwsgi ($package_location = "http://projects.unbit.it/downloads/uwsgi-1.4.1.tar.gz", $file_name = "uwsgi-1.4.1",) {
  group { "uwsgi": ensure => "present", }

  user { "uwsgi":
    ensure     => present,
    gid        => "uwsgi",
    managehome => false,
    shell      => '/bin/sh',
    require    => Group["uwsgi"],
  }

  exec { "uwsgi":
    cwd     => '/home/datawinners/workspace/datawinners',
    path    => ['/usr/local/bin', '/usr/bin', '/bin'],
    command => "source /home/datawinners/virtual_env/datawinners/bin/activate && sudo pip install uWSGI==1.4.1",
  }

  file { '/var/log/uwsgi':
    ensure => 'directory',
    owner  => 'uwsgi',
    group  => 'uwsgi',
    mode   => "0755",
  }

}

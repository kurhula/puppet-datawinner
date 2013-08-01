package { 'git-core':
    ensure => installed,
}
group{"datawinners": ensure => "present",}
user { "datawinners":
  ensure     => "present",
  managehome => true,
  gid => "datawinners",
  require => Group["datawinners"],
}
class {'python': virtualenv => true}
python::virtualenv { '/home/datawinners/virtual_env/datawinner':
  ensure       => present,
  owner        => "datawinners",
  group        => "datawinners",
}
python::pip {"pip":
  virtualenv  => '/home/datawinners/virtual_env/datawinner',
  owner       => 'datawinners',
  require     => User["datawinners"],
}

vcsrepo { '/home/datawinners/workspace/datawinners':
  ensure => present,
  provider => git,
  source => 'git://github.com/mangroveorg/datawinners.git',
}

vcsrepo { '/home/datawinners/workspace/mangrove':
  ensure => present,
  provider => git,
  source => 'git://github.com/mangroveorg/mangrove.git',
}

python::requirements { '/home/datawinners/workspace/datawinners/requirements.pip':
  virtualenv => '/home/datawinners/virtual_env/datawinner',
  owner      => 'datawinners',
  group      => 'datawinners',
}

python::requirements { '/home/datawinners/workspace/mangrove/requirements.pip':
  virtualenv => '/home/datawinners/virtual_env/datawinner',
  owner      => 'datawinners',
  group      => 'datawinners',
}


class { 'uwsgi':} 
uwsgi::plugin { 'python': ensure => present, }
uwsgi::app { 'datawinners':
    require => User["datawinners"],
    socket    => ":9001",
    plugins   => "python",
    env       =>  "DJANGO_SETTINGS_MODULE=datawinners.settings",
    virtualenv => "/home/datawinners/virtual_env",
    pythonpath => "/home/datawinners/virtual_env",
    uid        => "datawinners",
    gid        => "datawinners",
    chdir      => "/home/datawinners/workspace/datawinners/datawinners",
    home      => "/home/datawinners/virtual_env",
    module    =>   "django.core.handlers.wsgi:WSGIHandler()",
}


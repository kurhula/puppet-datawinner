node base_system{
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
		
	
  class {"postgresql":}
  class { 'java':
  distribution => 'jdk',
  version      => 'latest',
  }
  
  
  $pg_conf_include_file = "${postgresql::params::confdir}/postgresql_puppet_extras.conf"
  
  file { $pg_conf_include_file:
    content => 'standard_conforming_strings = off',
    notify  => Service['postgresqld'],
  }
  postgresql::database_user{ 'mangrove':
    # TODO: ensure is not yet supported
    #ensure        => present,
    password_hash => postgresql_password('mangrove', ''),
    require       => Class['postgresql::server'],
  }
  class {"tomcat":
  }
  class { 'couchdb': bind => '0.0.0.0' }
  
}

node dev inherits base_system{
  class{"datawinnersapp":}
  
}

node ci inherits dev {
  class { 'jenkins': }

  jenkins::plugin {
    'git' : ;
  }
}

node default inherits dev{}

class couchdb (
  $package_location = 'https://github.com/mangroveorg/dwpkg/raw/master/couchdb/apache-couchdb_1.3.1-1_amd64.deb',
  $package_name = 'apache-couchdb_1.3.1-1_amd64.deb'
)
 {

  group {"couchdb": ensure => "present",}

  user { "couchdb" : 
	ensure => present,
	gid => "couchdb",
  	managehome => false,
	shell => '/bin/sh',
	home => '/opt/apache-couchdb',
  }
  
  $required_packages = ['wget','libicu-dev', 'libmozjs185-dev', 'libcurl4-gnutls-dev', 'libtool', 'erlang-base-hipe','erlang-eunit','erlang-nox','erlang-xmerl', 'erlang-inets']
  package { $required_packages :
	ensure => 'installed',
  }

  exec { 'download':
    require => Package[$required_packages],
    cwd => '/opt/',
    path => [ '/usr/local/bin', '/usr/bin', '/bin', ],   
    command => "wget -q ${package_location} -O ${package_name}",
    timeout => 120,
  }
  
  file { "/opt/${package_name}" :
    require => Exec['download'],
    ensure => 'present',
    mode => '0755',	
  }
  
  exec { 'install-couchdb':
   require => File["/opt/${package_name}"],
   path => [ '/usr/local/bin', '/usr/sbin', '/sbin', '/usr/bin', '/bin', ],
   cwd => '/opt/',
   command => "dpkg -i ${package_name}",
   timeout => 120,		
  }

  file { ["/opt/apache-couchdb/var",
          "/opt/apache-couchdb/var/lib",
	  "/opt/apache-couchdb/var/log", 
	  "/opt/apache-couchdb/var/log/couchdb", 
   	  "/opt/apache-couchdb/var/run",
	  "/opt/apache-couchdb/var/run/couchdb"] :
      require => Exec['install-couchdb'],
      ensure => 'directory',
      owner => 'couchdb',
  }
}




class datawinners::couchdb($user) {
  
  limits::limits { 'couchdb_nofile':
        ensure     => present,
        user       => 'couchdb',
        limit_type => 'nofile',
        hard       => 65000,
        soft       => 65000,
  }
  
  limits::limits { "${user}_nofile":
        ensure     => present,
        user       => "${user}",
        limit_type => 'nofile',
        hard       => 65000,
        soft       => 65000,
  }
  file { "/etc/pam.d/common-session":
    content => template('datawinners/etc/pam.d/common-session.erb')
  }
  file { "/etc/pam.d/common-session-noninteractive":
    content => template('datawinners/etc/pam.d/common-session.erb')
  }
  
  # ############## Apache Couchdb configuration ###########
  # # couchdb user/group is created as part of the installation
  class { "::couchdb":
  }

  ::couchdb::instance { "couchdbmain":
    require      => Class['::couchdb'],
    service_name => "couchdbmain",
    database_dir => "/opt/apache-couchdb/var/lib/couchdbmain",
  }

  ::couchdb::instance { "couchdbfeed":
    require      => Class['::couchdb'],
    service_name => "couchdbfeed",
    database_dir => "/opt/apache-couchdb/var/lib/couchdbfeed",
    port         => "6984",
  }

}
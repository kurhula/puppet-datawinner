class datawinners::couchdb($user) {
  
  limits::limits { 'couchdb_nofile':
        ensure     => present,
        user       => 'couchdb',
        limit_type => 'nofile',
        hard       => 65000,
        soft       => 65000,
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

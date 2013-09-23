

class datawinners::limits($user){
	limits {"limits":
	      purge_limits_d_dir => false,
	}
	
	limits::limits { 'couchdb_nofile':
	      ensure     => present,
	      user       => 'couchdb',
	      limit_type => 'nofile',
	      hard       => 65000,
	      soft       => 65000,
	}
	
	limits::limits { '${user}_nofile':
	      ensure     => present,
	      user       => "${user}",
	      limit_type => 'nofile',
	      hard       => 65000,
	      soft       => 65000,
	}
  file { "/etc/pam.d/common-session":
    content => template('datawinners/pam.d/common-session.erb')
  }
  file { "/etc/pam.d/common-session-noninteractive":
    content => template('datawinners/pam.d/common-session.erb')
  }
}
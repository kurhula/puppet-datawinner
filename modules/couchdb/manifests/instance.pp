class couchdb::instance ($service_name='couchdb') {
     file { "/etc/init.d/${service_name}" :
	owner => 'root',
	group => 'root',
	mode => '0555',
     	content => template('couchdb/etc/init.d/couchdb_template.erb'),
     }
}

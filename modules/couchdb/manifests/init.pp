class couchdb (
  $package_location = 'https://github.com/mangroveorg/dwpkg/blob/master/apache-couchdb_1.3.0-1_amd64.deb',
  $package_name = 'apache-couchdb_1.3.0-1_amd64.deb'

) {
  exec { 'download':
    require => Package['curl'],
    cwd => '/opt/',
    command => "wget -q ${package_loaction} -O ${package_name}",
    timeout => 120
  }
}
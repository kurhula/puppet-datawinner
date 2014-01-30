
class datawinners::elasticsearch ($url) {
  $elasticsearch_package = url_parse($url, 'filename')

  exec { "download-elasticsearch":
    cwd       => "/var/tmp",
    path      => '/usr/local/bin:/bin:/sbin:/usr/bin:/usr/sbin',
    logoutput => "on_failure",
    command   => "wget ${url}",
    creates => "/var/tmp/${elasticsearch_package}",
  }

  package { "elasticsearch-install":
    source   => "/var/tmp/${elasticsearch_package}",
    provider => dpkg,
    require  => Exec['download-elasticsearch'],
  } 
  file { "/etc/init.d/elasticsearch":
    content => template('datawinners/etc/init.d/elasticsearch.erb'),
    mode => 755,
    require => Package["elasticsearch-install"],
  }

  file { "/etc/elasticsearch/elasticsearch.yml":
    content => template('datawinners/etc/elasticsearch/elasticsearch.yml.erb'),
    require => [Package["elasticsearch-install"],File['/etc/init.d/elasticsearch']],
    notify => Service["elasticsearch"]
  }

  service { "elasticsearch":
    ensure  => running,
    enable  => true,
  }
}
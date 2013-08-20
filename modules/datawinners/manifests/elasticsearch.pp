
class datawinners::elasticsearch ($url = "https://download.elasticsearch.org/elasticsearch/elasticsearch/elasticsearch-0.90.3.deb") 
{
  $elasticsearch_package = url_parse($url, 'filename')

  exec { "download-elasticsearch":
    cwd     => "/var/tmp",
    path    => '/usr/local/bin:/bin:/sbin:/usr/bin:/usr/sbin',
    command => "wget ${url}",
  }

  package { "elasticsearch-install":
    source   => "/var/tmp/${elasticsearch_package}",
    provider => dpkg,
    require  => Exec['download-elasticsearch'],
  }

  file { "/etc/elasticsearch/elasticsearch.yml":
    content => template('datawinners/etc/elasticsearch/elasticsearch.yml.erb'),
    require => Package["elasticsearch-install"],
  }
}
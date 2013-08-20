
class datawinners::elasticsearch (
  $url                   = "https://download.elasticsearch.org/elasticsearch/elasticsearch/elasticsearch-0.90.3.deb") {
  $elasticsearch_package = url_parse($url,'filename')  
  puppi::netinstall { "elasticsearch":
    path                => '/usr/local/bin:/bin:/sbin:/usr/bin:/usr/sbin',
    url                 => "${url}",
    destination_dir     => "/var/tmp",
    postextract_command => "/usr/bin/dpkg -i ${elasticsearch_package}",
  }
}
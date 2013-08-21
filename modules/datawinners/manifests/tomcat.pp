
class datawinners::tomcat ($user, $group, $url) {
  $file_name = url_parse($url, 'filename')

  file { "/home/${user}/tomcat7":
    ensure => directory,
    owner  => $user,
    group  => $group,
  }

  puppi::netinstall { "tomcat7":
    path            => '/usr/local/bin:/bin:/sbin:/usr/bin:/usr/sbin',
    url             => $url,
    destination_dir => "/home/${user}/tomcat7",
    owner           => $user,
    group           => $group,
    require         => File["/home/${user}/tomcat7"],
  }
}

class datawinners::tomcat ($user, $group, $url) {
  $file_name = url_parse($url, 'filedir')

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
  file { "/etc/init.d/tomcat":
    ensure  => present,
    content => template("datawinners/etc/init.d/tomcat.erb"),
    owner   => $user,
    group   => $group,
    mode    => '755',
  } ->
  service { "tomcat":
    ensure => running,
    enable => true,
  }
}
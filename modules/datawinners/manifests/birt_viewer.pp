class datawinners::birt_viewer (
  $home_dir,
  $user,
  $group,
  $tomcat_package_name,
  $package_location = 'http://dwapppkg.github.io/birt-viewer/birt-viewer.gz') {
  $file_name = url_parse($package_location, 'filename')

  exec { 'download-birt-viewer':
    cwd     => '/opt/',
    path    => ['/usr/local/bin', '/usr/bin', '/bin',],
    command => "wget -q ${package_location} -O ${file_name}",
    timeout => 600,
  }

  exec { 'unzip-birt-viewer':
    path    => ['/usr/local/bin', '/usr/bin', '/bin',],
    cwd     => "/home/${user}/tomcat7/${tomcat_package_name}/webapps/",
    command => "tar -xzvf /opt/${file_name}",
    user    => $user,
    require => Exec['download-birt-viewer'],
  }

  $array = split($file_name, '\.')
  $webapp_name = $array[0]

  exec { 'link-custom-reports':
    path    => ['/usr/local/bin', '/usr/bin', '/bin',],
    cwd     => "/home/${user}/tomcat7/${tomcat_package_name}/webapps/${webapp_name}",
    command => "ln -sf /home/${user}/workspace/custom_reports/crs /home/${user}/tomcat7/${tomcat_package_name}/webapps/${webapp_name}/crs",
    user    => $user,
    require => Exec['unzip-birt-viewer'],
  }

  $db_user = $user
  $db_password = $user

  file { "/home/${user}/tomcat7/${tomcat_package_name}/webapps/${webapp_name}/META-INF/context.xml":
    ensure  => present,
    owner   => "${user}",
    group   => "${group}",
    mode    => '0744',
    content => template('datawinners/birt-viewer/context.xml.erb'),
    require => Exec['unzip-birt-viewer'],
  }

}
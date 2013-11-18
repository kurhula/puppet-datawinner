class datawinners::phantomjs ($user) {

  $version      = '1.9.2'
  $basename     = "phantomjs-${version}-linux-x86_64"
  $tarball      = "${basename}.tar.bz2"
  $tarball_path = "/opt/${tarball}"
  $url          = "http://phantomjs.googlecode.com/files/${tarball}"
  $destdir      = "/opt/${basename}"


  puppi::netinstall { "phantomjs":
    path                => '/usr/local/bin:/bin:/sbin:/usr/bin:/usr/sbin',
    url                 => "${url}",
    destination_dir     => "/opt",
    owner               => $user,
    group               => $user,
    postextract_command => "ln -s ${destdir}/bin/phantomjs /usr/bin/phantomjs",
  }
}

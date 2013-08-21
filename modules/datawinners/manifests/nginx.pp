class datawinners::nginx ($home_dir, $package_location, $package_name) {
  class { "datawinners::nginx_config":
    home_dir         => $home_dir,
    package_location => $package_location,
    package_name     => $package_name
  } ->
  service { "nginx":
    ensure => running,
    enable => true,
  }
}

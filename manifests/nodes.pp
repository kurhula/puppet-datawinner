node base_system {
  $user_name = "datawinners"

  class { "datawinners":
    user  => $user_name,
    group => $user_name,
  }

  exec { "install_mangrove_egg":
    cwd     => "/home/${user_name}/workspace/mangrove/",
    command => "/bin/sh -c \". /home/${user_name}/virtual_env/datawinners/bin/activate && cd /home/${user_name}/workspace/mangrove && /home/${user_name}/virtual_env/datawinners/bin/python  /home/${user_name}/workspace/mangrove/setup.py develop\"",
    logoutput => "on_failure",
    require => Class["datawinners"],
  }
}

node /(dwdev)\..*/ inherits base_system { # dev
  file { "/home/${user_name}/workspace/datawinners/datawinners/local_settings.py":
    source => "/home/${user_name}/workspace/datawinners/datawinners/config/local_settings_example.py",
    ensure => present,
    owner  => $user_name,
    group  => $user_name,
  }

  exec { "Setup Development environment":
    cwd       => "/home/${user_name}/workspace/datawinners/",
    command   => "/bin/sh -c \". /home/${user_name}/virtual_env/datawinners/bin/activate \
      && cd /home/${user_name}/workspace/datawinners \
      && /home/${user_name}/workspace/datawinners/build.sh rsdb\"",
    user      => $user_name,
    logoutput => "on_failure",
    require   => [
      Exec["initialize-datawinners-environment"],
      File["/home/${user_name}/workspace/datawinners/datawinners/local_settings.py"],
      Exec["install_mangrove_egg"]],
      notify=> Service["uwsgi"],
  }
}

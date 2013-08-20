node base_system {
    $user_name = "datawinners"
    class { "datawinners":
        user => $user_name,
        group => $user_name,
    }
}


node default inherits base_system { #dev
  exec {"Setup Development environment":
    cwd => "/home/${user_name}/workspace/datawinners/",
    command => "/home/${user_name}/workspace/datawinners/build.sh rsdb",
    user => $user_name, 
    require => Exec["initialize-datawinners-environment"],
  }
}

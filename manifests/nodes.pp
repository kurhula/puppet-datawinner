node base_system {
    class { "datawinners": }
}

node default inherits base_system { #dev
  exec {"Setup Development environment":
    cwd => "/home/datawinners/workspace/datawinners/",
    command => "./build.sh rsdb", 
    require => Exec["initialize-datawinners-environment"],
  }
}

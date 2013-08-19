node base_system {
    class { "datawinners": }
}

node default inherits base_system {
}

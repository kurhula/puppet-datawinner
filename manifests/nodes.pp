node base_system {
  class { "datawinners": }
}

node dwdev inherits base_system{
}

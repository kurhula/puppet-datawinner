define datawinners::jenkins_job () {
  $job_name = $title
  file { "/var/lib/jenkins/jobs/${job_name}":
    ensure => directory,
    owner  => 'jenkins'
  }

  file { "/var/lib/jenkins/jobs/${job_name}/config.xml":
    source => "puppet:///datawinners/jenkins/jobs/${job_name}/config.xml",
    ensure => "present",
    owner  => "jenkins"
  }
}

class datawinners::jenkins {
  package {"curl":
    ensure => present,
  }->
  package {"xvfb":
    ensure => present,
  }->
  class { '::jenkins':
    plugin_hash => {
      git => { version => '1.1.1' },
      'greenballs' => { version => '1.12' },
      'cobertura' => { version => '1.9.2'},
      'build-pipeline-plugin' => { version => '1.3.5'},
      'disk-usage' => { version => '0.20'},
      'jobConfigHistory' => { version => '2.4'},
      'sidebar-link' => { version => '1.6'},
      'radiatorviewplugin' => { version => '1.13'},
      'show-build-parameters' => { version => '1.0'},
      'ssh-credentials' => { version => '1.3'},
      'ssh-slaves' => { version => '1.2'},
    }
  }->
  file {"/var/lib/jenkins/config.xml":
    source => "puppet:///datawinners/jenkins/config.xml",
    owner => "jenkins",
  } ->
  file {"/home/jenkins":
    ensure => directory,
    owner => "jenkins",
    mode => 755,
  } ->
  file { '/home/mangrover/datawinners':
      ensure => link,
      target => '/home/mangrover/workspace/datawinners',
  } ->
  file { '/home/mangrover/mangrove':
      ensure => link,
      target => '/home/mangrover/workspace/mangrove',
  } ->
  file { "/tmp/jenkins_requirement.txt":
    content => "fabric \nnose \ngunicorn"
  } ->
  ::python::virtualenv { "/home/jenkins/virtual_env/datawinners":
    ensure  => present,
    requirements => '/tmp/jenkins_requirement.txt',
    owner   => "jenkins",
    group   => "jenkins",
    require => Class['::python'],
  } ->
  exec {"create-jenkins-db-user":
    command => '/usr/bin/psql postgres -tAc "SELECT 1 FROM pg_roles WHERE rolname=\'jenkins\'" | grep -q 1 || /usr/bin/createuser --super jenkins',
    user => 'postgres',
  } ->
  exec {"create-jenkins-testing-db":
    command => '/usr/bin/psql -l|grep testingdb>>/dev/null || /usr/bin/createdb testingdb',
    user => 'postgres',
  } ->
  exec {"set_git_username":
    command => "/usr/bin/git config --global user.name Jenkins && /usr/bin/git config --global user.email 'jenkins@example.com'"
  } ->
  exec {"add_jenkins_to_mangrover_group":
    command => "/usr/sbin/usermod  -a -G mangrover jenkins",
  }
  #add git user name and email 
  
  datawinners::jenkins_job {"Mangrove-develop":} ->
  datawinners::jenkins_job {"Datawinners-develop":}->
  exec {"create_jenkins_key":
    command => "/usr/bin/ssh-keygen -t rsa -N '' -f /home/jenkins/.ssh/id_rsa",
    creates => "/home/jenkins/.ssh/id_rsa",
    user => 'jenkins',
    require => File["/home/jenkins"],
  } -> exec  { "create_mangrove_key":
    command => "/usr/bin/ssh-keygen -t rsa -N '' -f /home/mangrover/.ssh/id_rsa",
    user => "mangrover",
    creates => "/home/mangrover/.ssh/id_rsa"
  } -> exec {"add_jenkins_key_to_mangrover":
    command => "/bin/cat /home/jenkins/.ssh/id_rsa.pub>>/home/mangrover/.ssh/authorized_keys",
    notify => Service["jenkins"]
  } 
  package{"firefox":
    ensure => present,
  }
  postgresql::pg_hba_rule{"postgres_jenkins_access":
    type => 'local',
    auth_method => 'trust',
    database => 'all',
    user => 'all',
  }
}
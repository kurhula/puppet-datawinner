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
  file {"/var/log/datawinners":
    ensure => directory,
    mode => 777,
  } ->
  package {"curl":
    ensure => present,
  }->
  exec {"create-jenkins-db-user":
    command => "/usr/bin/createuser --super jenkins && /usr/bin/createdb testingdb -T template_postgis",
  } ->
  exec {"set_git_username":
    command => "/usr/bin/git config --global user.name Jenkins && /usr/bin/git config --global user.email 'jenkins@example.com'"
  } ->
  #add git user name and email 
  
  datawinners::jenkins_job {"Mangrove-develop":} ->
  datawinners::jenkins_job {"Datawinners-develop":}
}
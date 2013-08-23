
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
    }
  }->
  file {"/var/lib/jenkins/config.xml":
    source => "puppet:///datawinners/jenkins/config.xml",
    owner => "jenkins",
  }->
  file {"/tmp/jenkins_jobs.tar.gz":
    source => "puppet:///datawinners/jenkins/jenkins_jobs.tar.gz",
    owner => "jenkins",    
  }->
  exec {"extract_jenkins_jobs":
    command => "tar -xvzf /tmp/jenkins_jobs.tar.gz",
    cwd => "/var/lib/jenkins",
    user => "jenkins",
    notify => Service["jenkins"],
  }
  
}
class jobs_exporter::webapp {
  include 'docker'
  
  file { 'docker-logic_webapp':
    ensure => 'directory',
    path => '/centos/docker-logic_webapp/',
    recurse => true,
    source => "puppet:///modules/jobs_exporter/docker-logic_webapp"
  }

  file { '/centos/pdf':
    ensure => 'directory',
  }

  file { '/centos/plots':
    ensure => 'directory',
  }

  file { '/centos/pies':
    ensure => 'directory',
  }
  
  docker::image { 'webapp':
    docker_dir => '/centos/docker-logic_webapp/'
  }

  docker::run { 'start_webapp':
    image => 'webapp',
    ports => '5000',
    expose => '5000'
  }
}


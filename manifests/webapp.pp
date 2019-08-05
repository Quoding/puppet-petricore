class jobs_exporter::webapp {
  package { 'python36-pip':
    ensure => 'latest'
  }
  package { 'python36-requests':
    ensure => 'latest'
  }
  package { 'texlive':
    ensure => 'latest'
  }
  package { 'texlive-lastpage':
    ensure => 'latest'
  }
  package { 'flask' :
    ensure => 'latest',
    provider => 'pip3'
  }
  package { 'pylatex':
    ensure => 'latest',
    provider => 'pip3',
    require => Package['texlive']
  }
  package { 'requests':
    ensure => 'latest',
    provider => 'pip3'
  }
  package { 'matplotlib':
    ensure => 'latest',
    provider => 'pip3'
  }
  file { 'logic_webapp':
    ensure => 'present',
    path => '/centos/logic_webapp',
    source => "puppet:///modules/jobs_exporter/logic_webapp.py"
  }
  file { 'job.py':
    ensure => 'present',
    path => '/centos/job.py',
    source => "puppet:///modules/jobs_exporter/job.py"
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
  exec { 'start logic_webapp':
    command => '/usr/bin/python36 /centos/logic_webapp',
  }
}


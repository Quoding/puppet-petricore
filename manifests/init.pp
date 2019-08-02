wqclass jobs_exporter {
  package { 'python36-psutil':
    ensure => 'installed'
  }
  file { 'jobs_exporter.service':
    ensure => 'present',
    path => '/etc/systemd/system/jobs_exporter.service',
    source => "puppet:///modules/jobs_exporter/jobs_exporter.service"
  }

  file { 'jobs_exporter':
    ensure => 'present',
    path => '/usr/sbin/jobs_exporter',
    source => "puppet:///modules/jobs_exporter/jobs_exporter.py"
  }

  service { 'jobs_exporter':
    ensure => 'running',
    enable => true
  }


}


<<<<<<< HEAD
wqclass jobs_exporter {
=======
class jobs_exporter {
>>>>>>> 102696dcc7212d4ca01b2eed2ecee2a877bc8a73
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
<<<<<<< HEAD


=======
>>>>>>> 102696dcc7212d4ca01b2eed2ecee2a877bc8a73
}


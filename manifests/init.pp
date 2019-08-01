file { 'jobs_exporter.service':
  ensure => present,
  path => '/etc/systemd/system/jobs_exporter.service',
  source => "puppet:///modules/jobs_exporter/files/jobs_exporter.service",
}

file { 'jobs_exporter':
  ensure => present,
  path => '/usr/sbin/jobs_exporter',
  source => "puppet:///modules/jobs_exporter/files/jobs_exporter",
}

service { 'jobs_exporter':
  ensure => 'started',
  enable => true,
}

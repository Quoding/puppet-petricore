class jobs_exporter {
  
  include prometheus::pushgateway
  consul::service { 'pushgateway':
    port => 9091,
    tags => ['monitor'],
  }

  exec { 'jobs_exporter_venv':
    command => '/usr/bin/python36 -m venv /opt/jobs_exporter',
    creates => '/opt/jobs_exporter/bin/python',
    require => Package['python36']
  }

  exec { 'pip_prometheus':
    cwd => "/opt/jobs_exporter/bin/",
    command => "/opt/jobs_exporter/bin/pip install prometheus_client",
    creates => "/opt/jobs_exporter/lib/python3.6/site-packages/prometheus_client/",
    require => Exec['jobs_exporter_venv']
  }

  exec { 'pip_psutil_wheel':
    command => "/opt/jobs_exporter/bin/pip install psutil --find-links /cvmfs/soft.computecanada.ca/custom/python/wheelhouse/generic/ --prefer-binary",
    creates => "/opt/jobs_exporter/lib/python3.6/site-packages/psutil/",
    require => Exec['jobs_exporter_venv']
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
    enable => true,
    require => File['jobs_exporter.service', 'jobs_exporter']
  }
}

class jobs_exporter {
  include prometheus::pushgateway
  
  consul::service { 'pushgateway':
    port => 9091,
    tags => ['monitor'],
    token => lookup('profile::consul::acl_api_token')
  }

  #For cgdelete inside the Slurm epilog
  package { 'libcgroup-tools':
    ensure => 'installed'
  }

  exec { 'jobs_exporter_venv':
    command => '/usr/bin/python3 -m venv /opt/jobs_exporter',
    creates => '/opt/jobs_exporter/bin/python',
    require => Package['python3']
  }

  # exec { 'pip_upgrade':
  #   command => "/opt/jobs_exporter/bin/pip install --upgrade pip"
  # }

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

  # file { 'jobs_exporter.service':
  #   ensure => 'present',
  #   path => '/etc/systemd/system/jobs_exporter.service',
  #   source => "puppet:///modules/jobs_exporter/jobs_exporter.service"
  # }

  # file { 'jobs_exporter':
  #   ensure => 'present',
  #   path => '/usr/sbin/jobs_exporter',
  #   source => "puppet:///modules/jobs_exporter/jobs_exporter.py"
  # }

  file { '/opt/petricore':
    ensure => 'directory',
  }

  file { 'petricore-release':
    ensure => 'present',
    path => '/opt/petricore/petricore-release',
    source => "http://github.com/Quoding/petricore/archive/v0.01.tar.gz",
    replace => 'false'
  }

  exec {'unzip_release':
    command => "tar -xzf /petricore/petricore-release.tar.gz",
    creates => "/petricore/petricore-release"
  }

  exec { 'install.sh':
    command => "./centos/petricore-release/jobs_exporter/install.sh",
    creates => "/usr/sbin jobs_exporter"
  }

  service { 'jobs_exporter':
    ensure => 'running',
    enable => true,
    require => File['jobs_exporter.service', 'jobs_exporter']
  }
}

class petricore  {
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

  exec { 'pip_upgrade':
    command => "/opt/jobs_exporter/bin/pip install --upgrade pip",
    refreshonly => true,
    subscribe => Exec['jobs_exporter_venv']
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
    require => Exec['pip_upgrade']
  }

  file { '/opt/petricore':
    ensure => 'directory',
  }

  $petricore_version = lookup('petricore::version')

  archive { '/opt/petricore/petricore-release.tar.gz':
    ensure => 'present',
    extract => true,
    creates => '/opt/petricore/petricore-release',
    source => "http://github.com/Quoding/petricore/archive/v${petricore_version}.tar.gz",
    extract_flags => '--strip-components 1',
    require => File['/opt/petricore/'],
  }

  file { '/opt/petricore/jobs_exporter/install.sh':
    ensure => 'present',
    owner => 'root',
    group => 'root',
    mode  => '0700',
    require => Exec['untar_release']
  }

  exec { 'install.sh':
    cwd => "/opt/petricore/jobs_exporter/",
    command => "/bin/bash -c /opt/petricore/jobs_exporter/install.sh",
    creates => "/usr/sbin/jobs_exporter",
    require => File['/opt/petricore/jobs_exporter/install.sh']
  }

  service { 'jobs_exporter':
    ensure => 'running',
    enable => true,
    require => Exec['install.sh', "pip_psutil_wheel"]
  }
}

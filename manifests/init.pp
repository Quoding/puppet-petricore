class jobs_exporter {
  include prometheus::pushgateway

  require python::pyvenv
  
  consul::service { 'pushgateway':
    port => 9091,
    tags => ['monitor'],
    token => lookup('profile::consul::acl_api_token')
  }

  #For cgdelete inside the Slurm epilog
  package { 'libcgroup-tools':
    ensure => 'installed'
  }

  # exec { 'jobs_exporter_venv':
  #   command => '/usr/bin/python3 -m venv /opt/jobs_exporter',
  #   creates => '/opt/jobs_exporter/bin/python',
  #   require => Package['python3']
  # }

  # exec { 'pip_upgrade':
  #   command => "/opt/jobs_exporter/bin/pip install --upgrade pip"
  # }

  # exec { 'pip_prometheus':
  #   cwd => "/opt/jobs_exporter/bin/",
  #   command => "/opt/jobs_exporter/bin/pip install prometheus_client",
  #   creates => "/opt/jobs_exporter/lib/python3.6/site-packages/prometheus_client/",
  #   require => Exec['jobs_exporter_venv']
  # }

  # exec { 'pip_psutil_wheel':
  #   command => "/opt/jobs_exporter/bin/pip install psutil --find-links /cvmfs/soft.computecanada.ca/custom/python/wheelhouse/generic/ --prefer-binary",
  #   creates => "/opt/jobs_exporter/lib/python3.6/site-packages/psutil/",
  #   require => Exec['jobs_exporter_venv']
  # }

  python::pyvenv { '/opt/jobs_exporter':
    ensure => present,
  }

  python::pip { 'pip':
    ensure => latest,
    virtualenv => '/opt/jobs_exoprter',
  }

  python::pip { 'prometheus_client':
    ensure => present,
    pip_provider => 'pip3',
    virtualenv => '/opt/jobs_exporter',
  }

  python::pip { 'psutil':
    ensure => present,
    pip_provider => 'pip3',
    virtualenv => '/opt/jobs_exporter',
    install_args => '--find-links /cvmfs/soft.computecanada.ca/custom/python/wheelhouse/generic/ --prefer-binary'
  }

  file { '/opt/petricore':
    ensure => 'directory',
    before => File['petricore-release']
  }

  file { 'petricore-release':
    ensure => 'present',
    path => '/opt/petricore/petricore-release.tar.gz',
    source => "http://github.com/Quoding/petricore/archive/v0.01.tar.gz",
    replace => 'false',
    require => File['/opt/petricore/']
  }

  exec {'untar_release':
    cwd => "/opt/petricore/",
    command => "/bin/tar -xzf /opt/petricore/petricore-release.tar.gz --strip-components 1",
    creates => "/opt/petricore/README.md",
    require => File['petricore-release']
  }

  file { '/opt/petricore/jobs_exporter/install.sh':
    ensure => 'present',
    owner => 'root',
    group => 'root',
    mode  => '0700',
  }

  exec { 'install.sh':
    cwd => "/opt/petricore/jobs_exporter/",
    command => "/bin/bash -c /opt/petricore/jobs_exporter/install.sh",
    creates => "/usr/sbin jobs_exporter",
    require => Exec['untar_release']
  }

  service { 'jobs_exporter':
    ensure => 'running',
    enable => true,
    require => Exec['install.sh']
  }
}

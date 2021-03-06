class petricore  {
  include prometheus::pushgateway

  consul::service { 'pushgateway':
    port => 9091,
    tags => ['monitor'],
    token => lookup('profile::consul::acl_api_token')
  }

  file { '/opt/nvidia_smi_exporter': 
    ensure => 'directory'
  }

  # Commented out -> could work but it seems the github redirection to aws is buggy for now.
  # file { '/opt/nvidia_smi_exporter/nvidia_smi_exporter':
  #   ensure => 'present',
  #   source => "https://github.com/calculquebec/nvidia_smi_exporter/releases/download/v1.0/nvidia_smi_exporter",
  #   replace => 'false'
  # }

  package { 'wget':
    ensure => 'installed',
  }


  exec {'/bin/wget https://github.com/calculquebec/nvidia_smi_exporter/releases/download/v1.0/nvidia_smi_exporter':
    creates => '/opt/nvidia_smi_exporter/nvidia_smi_exporter',
    cwd => '/opt/nvidia_smi_exporter/',
    require => Package['wget']
  }

  file { '/opt/nvidia_smi_exporter/nvidia_smi_exporter':
    mode => '0700',
    owner => 'root'
  }

  #For cgdelete inside the Slurm epilog
  package { 'libcgroup-tools':
    ensure => 'installed'
  }

  package { 'python3-devel':
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
    ensure => 'directory'
  }

  $petricore_version = lookup('petricore::version')

  archive { '/opt/petricore.tar.gz':
    extract => true,
    extract_command => 'tar -xzf %s --strip-component 1',
    extract_path => '/opt/petricore/',
    creates => '/opt/petricore/README.md',
    source => "https://github.com/calculquebec/petricore/archive/v${petricore_version}.tar.gz",
    cleanup => true,
  }
  

  file { '/opt/petricore/jobs_exporter/install.sh':
    ensure => 'present',
    owner => 'root',
    group => 'root',
    mode  => '0700',
    require => Archive['/opt/petricore.tar.gz']
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

  service { 'nvidia_smi_exporter':
    ensure => 'running',
    enable => true,
    require => Exec['/bin/wget https://github.com/calculquebec/nvidia_smi_exporter/releases/download/v1.0/nvidia_smi_exporter', 'install.sh']
  }
  
  consul::service { 'nvidia_smi_exporter':
    port => 9101,
    tags => ['monitor'],
    token => lookup('profile::consul::acl_api_token')
  }
}

class jobs_exporter::db {
  require profile::slurm::accounting

  # file { '/opt/petricore_db':
  #   ensure => 'directory'
  # }

  # file { 'create_user_job_view.sh':
  #   ensure => 'present',
  #   source => "puppet:///modules/jobs_exporter/create_user_job_view.sh",
  #   path => "/opt/petricore_db/create_user_job_view.sh",
  #   owner => 'root',
  #   group => 'root',
  #   mode  => '0700',
  #   notify => Exec['/bin/bash -c /opt/petricore_db/create_user_job_view.sh'],
  #   require => File['/opt/petricore_db']
  # }

  file { '/opt/petricore':
    ensure => 'directory',
  }

  file { 'petricore-release':
    ensure => 'present',
    path => '/opt/petricore/petricore-release.tar.gz',
    source => "http://github.com/Quoding/petricore/archive/v0.01.tar.gz",
    replace => 'false',
    require => File['/opt/petricore/']
  }

  exec {'unzip_release':
    command => "/usr/bin/tar -xzf /opt/petricore/petricore-release.tar.gz",
    creates => "/opt/petricore/petricore-release",
    require => File['petricore-release']
  }

  exec { 'install.sh':
    command => "./opt/petricore/petricore-release/mgmt/install.sh",
    creates => "/opt/petricore_db/create_user_job_view.sh",
    require => Exec['unzip_release']
  }

  exec { '/bin/bash -c /opt/petricore_db/create_user_job_view.sh':
    require => File['create_user_job_view.sh'],
    subscribe => File['create_user_job_view.sh'],
    refreshonly => true,
    logoutput => true
  }

}

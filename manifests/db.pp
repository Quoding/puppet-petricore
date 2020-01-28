class jobs_exporter::db {
  require profile::slurm::accounting

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

  exec {'untar_release':
    cwd => "/opt/petricore/",
    command => "/bin/tar -xzf /opt/petricore/petricore-release.tar.gz --strip-component 1",
    creates => "/opt/petricore/README.md",
    require => File['petricore-release']
  }

    file { '/opt/petricore/mgmt/install.sh':
    ensure => 'present',
    owner => 'root',
    group => 'root',
    mode  => '0700',
  }

  exec { 'install.sh':
    cwd => "/opt/petricore/mgmt/",
    command => "/bin/bash -c /opt/petricore/mgmt/install.sh",
    creates => "/opt/petricore_db/create_user_job_view.sh",
    require => Exec['untar_release'],
    notify => Exec['/bin/bash -c /opt/petricore_db/create_user_job_view.sh'] 
  }

  exec { '/bin/bash -c /opt/petricore_db/create_user_job_view.sh':
    require => Exec['install.sh'],
    subscribe => Exec['install.sh'],
    refreshonly => true,
    logoutput => true
  }

}

class petricore::db(String $petricore_pass) {
  require profile::slurm::accounting

  file { '/opt/petricore':
    ensure => 'directory',
  }

  $petricore_version = lookup('petricore::version')

  file { 'petricore-release':
    ensure => 'present',
    path => '/opt/petricore/petricore-release.tar.gz',
    source => "http://github.com/Quoding/petricore/archive/v${petricore_version}.tar.gz",
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
    require => Exec['untar_release']
  }

  exec { 'install.sh':
    cwd => "/opt/petricore/mgmt/",
    command => "/bin/bash -c /opt/petricore/mgmt/install.sh",
    creates => "/opt/petricore_db/create_user_job_view.sh",
    require => File['/opt/petricore/mgmt/install.sh'],
    notify => Exec['/bin/bash -c /opt/petricore_db/create_user_job_view.sh'] 
  }

  file { 'config':
    ensure => 'present',
    path => '/opt/petricore_db/db_config',
    content => epp('petricore/db_config', {'password' => $petricore_pass}),
    require => Exec['install.sh'],
  }

  exec { '/bin/bash -c /opt/petricore_db/create_user_job_view.sh':
    subscribe => Exec['install.sh'],
    require => File['config'],
    refreshonly => true,
    logoutput => true
  }

}

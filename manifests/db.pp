class petricore::db(String $petricore_pass) {
  require profile::slurm::accounting


  file { '/opt/petricore':
    ensure => 'directory'
  }

  $petricore_version = lookup('petricore::version')

  archive { '/opt/petricore.tar.gz':
    extract => true,
    extract_command => 'tar -xzf /opt/petricore.tar.gz --strip-component 1',
    extract_path => '/opt/petricore/',
    creates => '/opt/petricore/README.md',
    source => "http://github.com/Quoding/petricore/archive/v${petricore_version}.tar.gz",
    cleanup => true,
  }

  file { '/opt/petricore/mgmt/install.sh':
    ensure => 'present',
    owner => 'root',
    group => 'root',
    mode  => '0700',
    require => Archive['/opt/petricore.tar.gz']
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

class jobs_exporter::db (String $domain_name) {
  file { '/opt/petricore_db':
    ensure => 'directory'
  }

  file { 'create_user_job_view.sh':
    ensure => 'present',
    source => "puppet:///modules/jobs_exporter/create_user_job_view.sh",
    path => "/opt/petricore_db/create_user_job_view.sh",
    owner => 'root',
    group => 'root',
    mode  => '0700',
    notify => Exec['/bin/bash -c /opt/petricore_db/create_user_job_view.sh'],
    require => File['/opt/petricore_db']
  }

  exec { '/bin/bash -c /opt/petricore_db/create_user_job_view.sh':
    require => File['create_user_job_view.sh'],
    subscribe => File['create_user_job_view.sh'],
    refreshonly => true,
    logoutput => true
  }

}
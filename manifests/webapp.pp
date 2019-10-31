class jobs_exporter::webapp {

  exec { 'webapp_venv':
    command => '/usr/bin/python3 -m venv /opt/webapp',
    creates => '/opt/webapp/bin/python',
    require => Package['python3']
  }

  exec { 'pip_flask':
    cwd => "/opt/webapp/bin/",
    command => "/opt/webapp/bin/pip install flask",
    creates => "/opt/webapp/lib/python3.6/site-packages/flask/",
    require => Exec['webapp_venv']
  }
  exec { 'pip_requests':
    cwd => "/opt/webapp/bin/",
    command => "/opt/webapp/bin/pip install requests",
    creates => "/opt/webapp/lib/python3.6/site-packages/requests/",
    require => Exec['webapp_venv']
  }
  exec { 'pip_pylatex':
    cwd => "/opt/webapp/bin/",
    command => "/opt/webapp/bin/pip install pylatex",
    creates => "/opt/webapp/lib/python3.6/site-packages/pylatex/",
    require => Exec['webapp_venv']
  }
  exec { 'pip_matplotlib':
    cwd => "/opt/webapp/bin/",
    command => "/opt/webapp/bin/pip install matplotlib",
    creates => "/opt/webapp/lib/python3.6/site-packages/matplotlib/",
    require => Exec['webapp_venv']
  }

  package { 'texlive':
    ensure => 'installed'
  }
  package { 'texlive-lastpage':
    ensure => 'installed'
  }

  file { 'logic_webapp':
    ensure => 'present',
    path => '/centos/logic_webapp.py',
    source => "puppet:///modules/jobs_exporter/logic_webapp.py"
  }
  file { 'job.py':
    ensure => 'present',
    path => '/centos/job.py',
    source => "puppet:///modules/jobs_exporter/job.py"
  }

  file { 'user.py':
    ensure => 'present',
    path => '/centos/user.py',
    source => "puppet:///modules/jobs_exporter/user.py"
  }
  file { '/centos/pdf':
    ensure => 'directory',
  }
  file { '/centos/plots':
    ensure => 'directory',
  }
  file { '/centos/pies':
    ensure => 'directory',
  }

  file { 'logic_webapp.service':
    ensure => 'present',
    path => '/etc/systemd/system/logic_webapp.service',
    source => "puppet:///modules/jobs_exporter/logic_webapp.service"
  }

  service { 'logic_webapp':
    ensure => 'running',
    enable => true,
    require => File['logic_webapp.service', 'logic_webapp']
  }
}


class jobs_exporter::webapp (String $domain_name){

  package {'mysql-devel':
    ensure => 'installed'
  }
  exec { 'webapp_venv':
    command => '/usr/bin/python3 -m venv /var/www/logic_webapp',
    creates => '/var/www/logic_webapp/bin/python',
    require => Package['python3']
  }
  
  exec { 'pip_flask':
    cwd => "/var/www/logic_webapp/bin/",
    command => "/var/www/logic_webapp/bin/pip install flask",
    creates => "/var/www/logic_webapp/lib/python3.6/site-packages/flask/",
    require => Exec['webapp_venv']
  }
  exec { 'pip_requests':
    cwd => "/var/www/logic_webapp/bin/",
    command => "/var/www/logic_webapp/bin/pip install requests",
    creates => "/var/www/logic_webapp/lib/python3.6/site-packages/requests/",
    require => Exec['webapp_venv']
  }
  exec { 'pip_pylatex':
    cwd => "/var/www/logic_webapp/bin/",
    command => "/var/www/logic_webapp/bin/pip install pylatex",
    creates => "/var/www/logic_webapp/lib/python3.6/site-packages/pylatex/",
    require => Exec['webapp_venv']
  }
  exec { 'pip_matplotlib':
    cwd => "/var/www/logic_webapp/bin/",
    command => "/var/www/logic_webapp/bin/pip install matplotlib",
    creates => "/var/www/logic_webapp/lib/python3.6/site-packages/matplotlib/",
    require => Exec['webapp_venv']
  }

  exec { 'pip_pymysql':
    cwd => "/var/www/logic_webapp/bin/",
    command => "/var/www/logic_webapp/bin/pip install pymysql",
    creates => "/var/www/logic_webapp/lib/python3.6/site-packages/pymysql/",
    require => Exec['webapp_venv']
  }

  package { 'texlive':
    ensure => 'installed'
  }

  package { 'texlive-lastpage':
    ensure => 'installed'
  }

  file { '/var/www/':
    ensure => 'directory'
  }

  file { 'logic_webapp':
    ensure => 'present',
    path => '/var/www/logic_webapp/logic_webapp.py',
    source => "puppet:///modules/jobs_exporter/logic_webapp.py"
  }

  file { 'config':
    ensure => 'present',
    path => '/var/www/logic_webapp/webapp_config',
    content => epp('jobs_exporter/webapp_config', {'domain_name' => $domain_name}),
  }

  file { 'job.py':
    ensure => 'present',
    path => '/var/www/logic_webapp/job.py',
    source => "puppet:///modules/jobs_exporter/job.py"
  }

  file { 'user.py':
    ensure => 'present',
    path => '/var/www/logic_webapp/user.py',
    source => "puppet:///modules/jobs_exporter/user.py"
  }
  file { '/var/www/logic_webapp/pdf':
    ensure => 'directory',
  }
  file { '/var/www/logic_webapp/plots':
    ensure => 'directory',
  }
  file { '/var/www/logic_webapp/pies':
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

class jobs_exporter::webapp (String $domain_name){

  require profile::reverse_proxy

    apache::vhost { 'petricore80_to_petricore443':
    servername      =>  "petricore.${domain_name}",
    port            => '80',
    redirect_status => 'permanent',
    redirect_dest   => "http://petricore.${domain_name}/",
    docroot         => false,
    manage_docroot  => false,
    access_log      => false,
    error_log       => false,
  }

  apache::vhost { 'petricore_ssl':
    servername                =>  "petricore.${domain_name}",
    port                      => '443',
    docroot                   => false,
    manage_docroot            => false,
    access_log                => false,
    error_log                 => false,
    proxy_dest                => 'http://127.0.0.1:5000',
    proxy_preserve_host       => true,
    rewrites                  => [
      {
        rewrite_cond => ['%{HTTP:Connection} Upgrade [NC]', '%{HTTP:Upgrade} websocket [NC]'],
        rewrite_rule => ['/(.*) wss://127.0.0.1:8000/$1 [P,L]'],
      },
    ],
    ssl                       => true,
    ssl_cert                  => "/etc/letsencrypt/live/${domain_name}/fullchain.pem",
    ssl_key                   => "/etc/letsencrypt/live/${domain_name}/privkey.pem",
    ssl_proxyengine           => true,
    ssl_proxy_check_peer_cn   => 'off',
    ssl_proxy_check_peer_name => 'off',
    headers                   => ['always set Strict-Transport-Security "max-age=15768000"']
  }

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

  file { '/opt/petricore':
    ensure => 'directory',
  }

  file { 'petricore-release':
    ensure => 'present',
    path => '/opt/petricore/petricore-release',
    source => "http://",
    replace => 'false'
  }

  exec {'unzip_release':
    command => "tar -xzf /petricore/petricore-release.tar.gz",
    creates => "/petricore/petricore-release"
  }

  exec { 'install.sh':
    command => "./centos/petricore-release/webapp/install.sh",
    creates => "/var/www/logic_webapp/"
  }

  # file { '/var/www/':
  #   ensure => 'directory'
  # }

  # file { 'logic_webapp':
  #   ensure => 'present',
  #   path => '/var/www/logic_webapp/logic_webapp.py',
  #   source => "puppet:///modules/jobs_exporter/logic_webapp.py"
  # }

  # file { 'db_access.py':
  #   ensure => 'present',
  #   path => '/var/www/logic_webapp/db_access.py',
  #   source => "puppet:///modules/jobs_exporter/db_access.py"
  # }

  file { 'config':
    ensure => 'present',
    path => '/var/www/logic_webapp/webapp_config',
    content => epp('jobs_exporter/webapp_config', {'domain_name' => $domain_name}),
  }

  # file { 'job.py':
  #   ensure => 'present',
  #   path => '/var/www/logic_webapp/job.py',
  #   source => "puppet:///modules/jobs_exporter/job.py"
  # }

  # file { 'user.py':
  #   ensure => 'present',
  #   path => '/var/www/logic_webapp/user.py',
  #   source => "puppet:///modules/jobs_exporter/user.py"
  # }
  # file { '/var/www/logic_webapp/pdf':
  #   ensure => 'directory',
  # }
  # file { '/var/www/logic_webapp/plots':
  #   ensure => 'directory',
  # }
  # file { '/var/www/logic_webapp/pies':
  #   ensure => 'directory',
  # }

  # file { 'logic_webapp.service':
  #   ensure => 'present',
  #   path => '/etc/systemd/system/logic_webapp.service',
  #   source => "puppet:///modules/jobs_exporter/logic_webapp.service"
  # }

  service { 'logic_webapp':
    ensure => 'running',
    enable => true,
    require => File['logic_webapp.service', 'logic_webapp']
  }
}

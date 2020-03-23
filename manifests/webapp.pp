class petricore::webapp (String $domain_name, String $petricore_pass){

  require profile::reverse_proxy

    apache::vhost { 'petricore80_to_petricore443':
    servername      =>  "petricore.${domain_name}",
    port            => '80',
    redirect_status => 'permanent',
    redirect_dest   => "https://petricore.${domain_name}/",
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

  package {'gcc':
    ensure => 'installed',
  }

  package {'python3-devel':
    ensure => 'installed'
  }
  package {'openldap-devel':
    ensure => 'installed'
  }

  exec { 'webapp_venv':
    command => '/usr/bin/python3 -m venv /var/www/logic_webapp',
    creates => '/var/www/logic_webapp/bin/python',
    require => Package['python3', 'gcc']
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

  exec { 'pip_ldap':
    cwd => "/var/www/logic_webapp/bin/",
    command => "/var/www/logic_webapp/bin/pip install python-ldap",
    creates => "/var/www/logic_webapp/lib/python3.6/site-packages/ldap/",
    require => Exec['webapp_venv']
  }

  package { 'texlive':
    ensure => 'installed'
  }

  package { 'texlive-lastpage':
    ensure => 'installed'
  }

  file { '/opt/petricore':
    ensure => 'directory'
  }

  $petricore_version = lookup('petricore::version')

  archive { '/opt/petricore.tar.gz':
    extract => true,
    extract_command => 'tar -xzvf %s --strip-component 1',
    extract_path => '/opt/petricore/',
    creates => '/opt/petricore/README.md',
    source => "http://github.com/Quoding/petricore/archive/v${petricore_version}.tar.gz",
    cleanup => true,
  }

  file { '/opt/petricore/webapp/install.sh':
    ensure => 'present',
    owner => 'root',
    group => 'root',
    mode  => '0700',
    require => Archive['/opt/petricore.tar.gz']
  }

  exec { 'install.sh':
    cwd => "/opt/petricore/webapp/",
    command => "/bin/bash -c /opt/petricore/webapp/install.sh",
    creates => "/var/www/logic_webapp/pdf/",
    require => File['/opt/petricore/webapp/install.sh']
  }

  file { 'config':
    ensure => 'present',
    path => '/var/www/logic_webapp/webapp_config',
    owner => 'root',
    group => 'root',
    mode  => '0700',
    content => epp('petricore/webapp_config', {'domain_name' => $domain_name, 'password' => $petricore_pass}),
    require => Exec['install.sh']
  }

  service { 'logic_webapp':
    ensure => 'running',
    enable => true,
    require => File['config']
  }
}

# piwik::nginx
#
# This definition/class installs NGINX + PHP-FPM and creates a 
# virtual host.
#
# == Parameters: 
#
# $name::     The name of the host
# $port::     The port to configure the host
# $docroot::  The location of the files for this host
# $user::     Under which user php-fpm should run
# $group::    Under which group php-fpm should run
#
# == Actions:
#
# == Requires: 
#
# The piwik class
#
# == Sample Usage:
#
#  piwik::nginx { 'nginx.piwik': }
#
#  piwik::nginx { 'nginx.piwik':
#    port     => 8080,
#    docroot  => '/var/www/piwik',
#    user     => 'piwik',
#    group    => 'www'
#  }
#

define piwik::nginx (
  $port    = 8080,
  $docroot = $piwik::params::docroot,
  $user    = $piwik::params::user,
  $group   = $piwik::params::group,
) {

  $socket_path = "${docroot}/tmp/fpm.socket"
  
  host { "${name}":
    ip => "127.0.0.1";
  } 
   
  include php::fpm::daemon 
  php::fpm::conf { 'www': ensure => absent }
  php::fpm::conf { "${name}":
    user => $user,
    group => $group,
    listen => $socket_path,
    listen_owner => $user,
    listen_group => $group,
    catch_workers_output => 'yes',
  }

  class { "nginx":
    manage_repo => false,  
  }

  nginx::resource::vhost { "${name}":
    ensure               => present,
    www_root             => $docroot,
    listen_port          => $port,
    use_default_location => false,
    index_files => [ 'index.php' ],
  }
  nginx::resource::location { "php-rewrite-${name}":
    location  => '~ \.php$',
    vhost => "${name}",
    fastcgi => "unix:${socket_path}",
    try_files => ['$uri =404'],
    index_files => ['index.php', 'index.html', 'index.htm'],
  }

}

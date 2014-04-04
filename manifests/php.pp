# = Class: piwik::php
# 
# This class installs PHP including all modules required by Piwik.
# Lots of useful PHP QA packages and Composer will be installed as well.
# 
# == Parameters: 
# 
# == Requires: 
# 
# == Sample Usage:
#
#  include piwik::php
#
class piwik::php {

  include php

  php::module { ['snmp', 'curl', 'xdebug', 'mysql', 'gd', 'sqlite', 'memcache', 'mcrypt', 'imagick', 'geoip', 'uuid', 'recode', 'cgi']: 
  }

  php::module::ini { [ 'pdo', 'pdo_mysql', 'mysqli' ]:
    pkgname => 'mysql',
  }

  class { 'pear': }
  class { 'phpqatools': require => Class['pear'] }

  pear::package { "PHPUnit_MockObject":
    repository => "pear.phpunit.de",
  }

  pear::package { "PHP_CodeCoverage":
    repository => "pear.phpunit.de",
  }

  pear::package { "PHPUnit_Selenium":
    repository => "pear.phpunit.de",
  }  

  exec { 'install_composer':
    command => 'curl -s https://getcomposer.org/installer | php -- --install-dir="/bin"',
    require => [ Package['curl'] ],
    unless  => 'which composer.phar',
  }

  exec { 'update_composer':
    environment => ['COMPOSER_HOME=/var/www/piwik'],
    command => 'php /bin/composer.phar self-update',
    require => [ Exec['install_composer'] ],
  }

  class { 'piwik::xhprof': }

  # TODO add channels... we should fork pear module and send pull requests
  # pear module should allow to add channels, do upgrade and install a
  # package only if not already installed
  # pear upgrade pear
  # pear channel-discover pear.phpunit.de
  # pear channel-discover pear.symfony-project.com
  # pear channel-discover components.ez.no
  # pear update-channels
  # pear upgrade-all
  # pear install --alldeps phpunit/PHPUnit

}

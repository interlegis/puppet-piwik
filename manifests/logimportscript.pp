#logimportscript.pp

class piwik::logimportscript ( $url,
                               $token_auth,
                               $idsite = undef,
                               $recorders = 4,
                               $add_sites_new_hosts = false,
                               $enable_http_errors = false,
                               $enable_static = false,
                               $enable_bots = false,
                               $enable_http_redirects = false,
                               $log_format_name = 'common_complete',
                               $log_file,
                               $execute_cmd_before = '',
                               $cron_hour = '7',
                               $cron_minute = '00',
                               $ensure = 'present',
                             ) {

  if $add_sites_new_hosts and $idsite {
    fail('You should either use add_sites_new_hosts or idsite, not both.')
  }

  validate_re($url,'^(https?)://.*$','You must provide a valid URL for the piwik server.')

  file { "/usr/local/bin/import_piwik.sh":
    owner => 'root', group => 'root', mode => '550',
    content => template('piwik/import_piwik.sh.erb'),
    ensure => $ensure,
  }

  include wget
  wget::fetch { "import_logs.py":
    source => "https://raw.githubusercontent.com/piwik/piwik-log-analytics/master/import_logs.py",
    destination => "/usr/local/bin/import_logs.py",
  }

  cron { "import_piwik":
    ensure => $ensure,
    hour => $cron_hour,
    minute => $cron_minute, 
    command => "/usr/local/bin/import_piwik.sh",
    environment => [ "MAILTO=root" ] ,
  }
}

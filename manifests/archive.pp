#archive.pp

class piwik::archive ( $ensure = 'present',
                       $mailto = 'root',
                       $cron_hour = '*',
                       $cron_minute = '5',
                       $cron_user = 'www-data',
                       $url = "http://$::fqdn",
                       $logfile = "/tmp/piwik-archive.log",
                       ) {

  validate_re($url,'^(https?)://.*$','You must provide a valid URL for the piwik server.')

  cron { "piwik_archive":
    ensure => $ensure,
    hour => $cron_hour,
    minute => $cron_minute,
    user => $cron_user,
    command => "/usr/bin/php5 ${piwik::directory}/misc/cron/archive.php --url=${url} > ${logfile}",
    environment => [ "MAILTO=$mailto" ],
  }
 
}

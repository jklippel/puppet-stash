# == Class: stash::service
#
# This manages the stash service. See README.md for details
# 
class stash::service  (

  $service_manage        = $stash::service_manage,
  $service_ensure        = $stash::service_ensure,
  $service_enable        = $stash::service_enable,
  $service_file_location = $stash::params::service_file_location,
  $service_file_template = $stash::params::service_file_template,
  $service_lockfile      = $stash::params::service_lockfile,

) {

  validate_bool($service_manage)

  file { $service_file_location:
    content => template($service_file_template),
    mode    => '0755',
  }

  if $stash::service_manage {

    validate_string($service_ensure)
    validate_bool($service_enable)

    if ( $::osfamily == 'RedHat' and $::operatingsystemmajrelease == '7' )
    or ( $::osfamily == 'Debian' and $::operatingsystemmajrelease == '8' ) {
      exec { 'refresh_systemd':
        command     => 'systemctl daemon-reload',
        refreshonly => true,
        subscribe   => File[$service_file_location],
        before      => Service["bitbucket"],
      }
    }

    service { "bitbucket":
      ensure  => $service_ensure,
      enable  => $service_enable,
      require => File[$service_file_location],
    }
  }

}

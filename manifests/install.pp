# == Class cpan::install
#
# Installs CPAN and dependencies required to install modules.
#
class cpan::install {
  if $cpan::manage_package {
    package { 'perl-cpan':
      ensure  => $cpan::package_ensure,
      name    => $cpan::package_name,
    }
  }

  if $cpan::local_lib {
    package { 'perl-cpan-local-lib':
      ensure  => 'present',
      name    => $cpan::local_lib_package,
    }
  }

  pick($cpan::support_packages, {}).each | String $name, Hash $attrs | {
    package {
      default: ensure => present,;
      $name:   *      => $attrs,;
    }
  }
}

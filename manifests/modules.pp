# == Class cpan::modules
#
# Installs Perl modules via CPAN.
#
class cpan::modules {
  pick($cpan::modules, {}).each | String $name, Hash $attrs, | {
    cpan {
      default: ensure => present,;
      $name:   *      => $attrs,;
    }
  }
}

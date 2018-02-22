# == Class: cpan::config
#
# Private class. Should not be called directly.
#
class cpan::config {
  if $::cpan::manage_config {
    file { $cpan::perl_config:
      ensure  => file,
      owner   => $cpan::root_user,
      group   => $cpan::root_group,
      mode    => '0644',
      content => template($::cpan::config_template),
    }
  }
}

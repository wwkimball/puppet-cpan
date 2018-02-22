# == Class: cpan
#
# Installs cpan
#
# === Parameters
#
# [*manage_config*]
#
# [*manage_package*]
#
# [*installdirs*]
#
# [*local_lib*]
#
# [*config_template*]
#
# [*config_hash*]
#
# [*package_ensure*]
#
# [*ftp_proxy*]
#
# [*http_proxy*]
#
# === Examples
#
# class {'::cpan':
#   manage_config  => true,
#   manage_package => true,
#   package_ensure => 'present',
#   installdirs    => 'site',
#   local_lib      => false,
#   config_hash    => { 'build_requires_install_policy' => 'no' },
#   ftp_proxy      => 'http://your_ftp_proxy.com',
#   http_proxy     => 'http://your_http_proxy.com',
#   modules        => {
#     'Clone::Closure' => {
#       ensure => present,
#       force  => true,
#     },
#     'Foo::Bar' => {
#       ensure    => present,
#       local_lib => '/opt',
#     }
#   }
# }
#
class cpan(
  Hash[String[1], Any]           $config_hash,
  String[3]                      $config_template,
  Enum['perl', 'site', 'vendor'] $installdirs,
  Boolean                        $local_lib,
  String[1]                      $local_lib_package,
  Boolean                        $manage_config,
  Boolean                        $manage_package,
  String[1]                      $package_ensure,
  String[1]                      $package_name,
  Stdlib::Absolutepath           $perl_config,
  Variant[String[1], Integer]    $root_group,
  Variant[String[1], Integer]    $root_user,
  Hash[
    String[1],
    Hash[String[1], Any]
  ]                              $support_packages,
  Array[Stdlib::HTTPUrl]         $urllist,
  Optional[Stdlib::HTTPUrl]      $ftp_proxy        = undef,
  Optional[Stdlib::HTTPUrl]      $http_proxy       = undef,
  Optional[Hash[
    Pattern[/^\w+(::\w+)*$/],
    Hash[
      String[1],
      Any
  ]]]                            $modules          = undef,
) {
  class { '::cpan::install': }
  -> class { '::cpan::config': }
  -> class { '::cpan::modules': }
  -> Class['cpan']
}

Puppet::Type.type(:cpan).provide(:default) do
  @doc = 'Manages cpan modules'

  commands cpan: 'cpan'
  commands perl: 'perl'
  confine  osfamily: %i[Debian DragonFly FreeBSD RedHat Windows]
  ENV['PERL_MM_USE_DEFAULT'] = '1'

  def install; end

  def force; end

  def latest?
    ll = "-Mlocal::lib=#{resource[:local_lib]}" if resource[:local_lib]
    current = `perl #{ll} -M#{resource[:name]} -e 'print $#{resource[:name]}::VERSION' 2>/dev/null;`
    return false if current == ''
    cpan_str = `perl #{ll} -e 'use CPAN; my $mod=CPAN::Shell->expand("Module","#{resource[:name]}"); printf("%s", $mod->cpan_version eq "undef" || !defined($mod->cpan_version) ? "-" : $mod->cpan_version);'`
    latest = cpan_str.match(/^[a-zA-Z]?([0-9]+.?[0-9]*\.?[0-9]*)$/)[1]
    if Puppet::Util::Package.versioncmp(latest.chomp, current.chomp) > 0
      return true
    end
    false
  end

  def create
    Puppet.info("Installing cpan module #{resource[:name]}")
    ll = "-Mlocal::lib=#{resource[:local_lib]}" if resource[:local_lib]
    umask = "umask #{resource[:umask]};" if resource[:umask]
    Puppet.debug("cpan #{resource[:name]}")
    if resource.force?
      Puppet.info("Forcing install for #{resource[:name]}")
      system("#{umask} yes | perl #{ll} -MCPAN -e 'CPAN::force CPAN::install #{resource[:name]}'")
    else
      system("#{umask} yes | perl #{ll} -MCPAN -e 'CPAN::install #{resource[:name]}'")
    end

    # cpan doesn't always provide the right exit code, so we double check
    system("perl #{ll} -M#{resource[:name]} -e1 > /dev/null 2>&1")
    estatus = $CHILD_STATUS.exitstatus

    raise Puppet::Error, "cpan #{resource[:name]} failed with error code #{estatus}" if estatus != 0
  end

  def destroy; end

  def update
    Puppet.info("Upgrading cpan module #{resource[:name]}")
    Puppet.debug("cpan #{resource[:name]}")

    ll = "-Mlocal::lib=#{resource[:local_lib]}" if resource[:local_lib]
    umask = "umask #{resource[:umask]};" if resource[:umask]

    if resource.force?
      Puppet.info("Forcing upgrade for #{resource[:name]}")
      system("#{umask} yes | perl #{ll} -MCPAN -e 'CPAN::force CPAN::install #{resource[:name]}'")
    else
      system("#{umask} yes | perl #{ll} -MCPAN -e 'CPAN::install #{resource[:name]}'")
    end
    estatus = $CHILD_STATUS.exitstatus

    raise Puppet::Error, "CPAN::install #{resource[:name]} failed with error code #{estatus}" if estatus != 0
  end

  def exists?
    ll = "-Mlocal::lib=#{resource[:local_lib]}" if resource[:local_lib]

    Puppet.debug("perl #{ll} -M#{resource[:name]} -e1 > /dev/null 2>&1")
    output = `perl #{ll} -M#{resource[:name]} -e1 > /dev/null 2>&1`
    estatus = $CHILD_STATUS.exitstatus

    case estatus
    when 0
      true
    when 2
      Puppet.debug("#{resource[:name]} not installed")
      false
    else
      raise Puppet::Error, "perl #{ll} -M#{resource[:name]} -e1 failed with error code #{estatus}: #{output}"
    end
  end
end

#Cloned interfaces

Facter.add("cloned_interfaces") do
  setcode do
    Facter::Util::Resolution.exec('/usr/local/bin/augtool -i get /files/etc/rc.conf/cloned_interfaces | /usr/bin/awk -F"=" \'{{print $2}}\' | /usr/bin/sed \'s/\"//g\' | /usr/bin/sed \'s/\ //g\' ')
  end
end

# vim: sts=4 ts=4 sw=4 expandtab autoindent
#
#Install and configure bridge for ezjail.
#

define puppet-ezjail::bridge (
    $autostart = true,
    $running = true,
    $bridge_name = undef,
    $ipaddress,
    $netmask,
)
{
	$path_freebsd = ["/bin", "/sbin","/usr/bin", "/usr/sbin", "/usr/local/bin", "/usr/local/sbin"]
    #
    $bridge_iface = $bridge_name ?{
            undef => $name,
            $bridge_name => $bridge_name,
    }

    #Create interfaces in rc.conf
    if ($autostart == true) {
        #Add interface to rc.conf
        augeas {"rc.conf_epairs_${name}":
            context => "/files/etc/rc.conf",
            changes => ["set cloned_interfaces '\"$cloned_interfaces $bridge_iface\"'"],
            onlyif => "match cloned_interfaces[. =~ regexp('.*$bridge_iface.*')] size == 0",
        }
        
        #Add interface ipaddress to rc.conf
        augeas {"rc.conf_inet_epairs_${name}":
            context => "/files/etc/rc.conf",
            changes => ["set ifconfig_${bridge_iface} '\"inet ${ipaddress} netmask ${netmask}\"'"],
            onlyif => "match ifconfig_${bridge_iface}[. =~ regexp('.*inet ${ipaddress} netmask ${netmask}.*')] size == 0",
            require => Augeas["rc.conf_epairs_${name}"],
        }

    }

    if ($running == true) {
        #create bridge 
		exec { "create_bridge_${name}":
			command => "ifconfig $bridge_iface create ",
			path => $path_freebsd,
			unless => "/sbin/ifconfig ${bridge_iface}"
		}
		
        #inet fori bridge 
        exec { "inet_bridge_${name}":
			command => "ifconfig ${bridge_iface} ${ipaddress} netmask ${netmask} up",
			path => $path_freebsd,
            require => Exec["create_bridge_${name}"],
			unless => "/sbin/ifconfig ${bridge_iface} | /usr/bin/grep ${ipaddress}"
		}

    }
}

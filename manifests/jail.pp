# vim: sts=4 ts=4 sw=4 expandtab autoindent
#
#INSTALL SKYPE ON DESKTOP
#

define puppet-ezjail::jail (
	$conf_dir = "/usr/local/etc/ezjail/",
	$owner = "root",
	$jail_name,
	$jail_hostname,
	$jail_rootdir = "/usr/jails/",
    $jail_ipaddress,
	$create = false,
	$running = false,
	$restart_on_change = true,
	$extra_parametrs = "persist allow.raw_sockets=1 allow.sysvipc=1",
    $vnet_interface = "",
    $autostart = true,
    $create_ifaces_epair = true,
    $inet_epair_a,
    $netmask_epair_a,
)
{
	
	$path_freebsd = ["/bin", "/sbin","/usr/bin", "/usr/sbin", "/usr/local/bin", "/usr/local/sbin"]
    #Create interfaces in rc.conf
    if ($autostart == true) {
        #Add interface to rc.conf
        augeas {"rc.conf_epairs_${name}":
            context => "/files/etc/rc.conf",
            changes => ["set cloned_interfaces '\"$cloned_interfaces $vnet_interface\"'"],
            onlyif => "match cloned_interfaces[. =~ regexp('.*$vnet_interface.*')] size == 0",
        }
        
        #Add interface ipaddress to rc.conf
        augeas {"rc.conf_inet_epairs_${name}":
            context => "/files/etc/rc.conf",
            changes => ["set ifconfig_${vnet_interface}a '\"inet ${inet_epair_a} netmask ${netmask_epair_a}\"'"],
            onlyif => "match ifconfig_${vnet_interface}a[. =~ regexp('.*inet ${inet_epair_a} netmask ${netmask_epair_a}.*')] size == 0",
            require => Augeas["rc.conf_epairs_${name}"],
        }

    }

    if ($create_ifaces_epair == true) {
        #create epair
		exec { "create_epair_${name}":
			command => "ifconfig $vnet_interface create ",
			path => $path_freebsd,
			unless => "/sbin/ifconfig ${vnet_interface}a"
		}
		
        #inet for epair
        exec { "inet_epair_${name}":
			command => "ifconfig ${vnet_interface}a ${inet_epair_a} netmask ${netmask_epair_a} up",
			path => $path_freebsd,
            require => Exec["create_epair_${name}"],
			unless => "/sbin/ifconfig ${vnet_interface}a | /usr/bin/grep ${inet_epair_a}"
		}

    }
    #
	$require_test = $create ? {
		true  => Exec["create-ezjail_${name}"],
		false => undef, 
	}

	$restart_jail = $restart_on_change ? {
		true => File["config_${name}"],
		false => undef, 
	}

	file { "config_${name}":
        path => "$conf_dir/$jail_name",
		replace => "yes",
		owner   => $owner,
		mode    => 600,
		content => template('puppet-ezjail/conf_jail.xml'),
		require => $require_test,
	}

	exec{"restart_jail_${name}": 
		command => "ezjail-admin restart $jail_hostname", 
		path => $path_freebsd,
		refreshonly  => true,
		subscribe => $restart_jail, 
	}
	
	
	#Template for new jail

	if ( $create == true ) {
		exec { "create-ezjail_${name}":
			command => "ezjail-admin create -r $jail_rootdir/$jail_hostname $jail_name $jail_ipaddress",
			path => $path_freebsd,
			unless => '/bin/test -b $jail_rootdir/$jail_hostname'
		}
	}
	
	if ( $running == true ){
		exec { "running-ezjail_${name}":
			command => "ezjail-admin start $jail_hostname",
			path => $path_freebsd,
			require => File["config_${name}"],
			unless => "/usr/sbin/jls | /usr/bin/grep $jail_hostname"
		}
	}	
}

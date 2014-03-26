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
	$create = false,
	$running = false,
	$restart_on_change = true,
	$extra_parametrs = "persist allow.raw_sockets=1 allow.sysvipc=1",
    $vnet_interface = "",
)
{
	
	$path_freebsd = ["/bin", "/sbin","/usr/bin", "/usr/sbin", "/usr/local/bin", "/usr/local/sbin"]
    #Create interfaces in rc.conf
    augeas {"rc.conf_bridge":
        context => "/files/etc/rc.conf",
        changes => ["set cloned_interfaces '\" $cloned_interfaces $vnet_interface \"'"],
        onlyif => "match cloned_interfaces include $vnet_interface",
    }

    #
	$require_test = $create ? {
		true  => Exec["create-ezjail"],
		false => undef, 
	}

	$restart_jail = $restart_on_change ? {
		true => File["$conf_dir/$jail_name"],
		false => undef, 
	}

	file { "$conf_dir/$jail_name":
		replace => "yes",
		owner   => $owner,
		mode    => 600,
		content => template('puppet-ezjail/conf_jail.xml'),
		require => $require_test,
	}

	exec{"restart_jail": 
		command => "ezjail-admin restart $jail_hostname", 
		path => $path_freebsd,
		refreshonly  => true,
		subscribe => $restart_jail, 
	}
	
	
	#Template for new jail

	if ( $create == true ) {
		exec { "create-ezjail":
			command => "ezjail-admin create -r $jail_rootdir/$jail_hostname $jail_name $jail_ipaddress",
			path => $path_freebsd,
			unless => '/bin/test -d $jail_rootdir/$jail_hostname'
		}
	}
	
	if ( $running == true ){
		exec { "running-ezjail":
			command => "ezjail-admin start $jail_hostname",
			path => $path_freebsd,
			require => File["$conf_dir/$jail_name"],
			unless => "/usr/sbin/jls | /usr/bin/grep $jail_hostname"
		}
	}	
}

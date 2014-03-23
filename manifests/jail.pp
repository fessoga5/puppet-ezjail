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
	$jail_gateway,
	$create = false,
	$running = false,
)
{
	$path_freebsd = ["/bin", "/sbin","/usr/bin", "/usr/sbin", "/usr/local/bin", "/usr/local/sbin"]
	#Template for new jail
	file { "$conf_dir/$jail_name":
		replace => "yes",
		owner   => $owner,
		mode    => 600,
		content => template('puppet-ezjail/conf_jail.xml'),
      	}

	if ( $create == true ) {
		exec { "ezjail-admin create -r $jail_rootdir/$jail_hostname $jail_name $jail_ipaddress":
			path => $path_freebsd,
			require => File["$conf_dir/$jail_name"]
		}
	}
	
	if ( $running == true ){
		exec {"ezjail-admin start $jail_hostname":
			path => $path_freebsd,
			require => File["$conf_dir/$jail_name"]
		}
	}	
}

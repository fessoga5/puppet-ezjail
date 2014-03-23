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
	
	$require_test = $create ? {
		true  => Exec["create-ezjail"],
		false => undef, 
	}
	
	$path_freebsd = ["/bin", "/sbin","/usr/bin", "/usr/sbin", "/usr/local/bin", "/usr/local/sbin"]
	#Template for new jail
	file { "$conf_dir/$jail_name":
		replace => "yes",
		owner   => $owner,
		mode    => 600,
		content => template('puppet-ezjail/conf_jail.xml'),
		require => $require_test
      	}

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
			unless => '/usr/sbin/jls | grep sf$jail_hostname'
		}
	}	
}

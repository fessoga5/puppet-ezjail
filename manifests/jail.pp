# vim: sts=4 ts=4 sw=4 expandtab autoindent
#
#INSTALL SKYPE ON DESKTOP
#
define puppet-ezjail::jail (
	$conf_dir = "/usr/local/etc/ezjail/",
	$owner = "root",
	$jail_name,
	$jail_rootdir = "/usr/jails/",
	$jail_hostname,
)
{
	#Template for new jail
	file { "$conf_dir/$jail_name":
		replace => "yes",
		owner   => $owner,
		mode    => 600,
		content => template('puppet-ezjail/conf_jail.xml'),
      	}	
}

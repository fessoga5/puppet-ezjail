# vim: sts=4 ts=4 sw=4 expandtab autoindent
#
#INSTALL ezjail host on Freebsd 10 
#Module for install and managment ezjail on Freebsd 10! 
#autor: fessoga5@gmail.com
#
class puppet-ezjail ($force_install = false, $enabled = false) {
    #autostart. Add to rc.conf
    $rc_status = $enabled ? {
        true => "YES",
        false => "NO",
    }

    augeas {"rc.conf":
        context => "/files/etc/rc.conf",
        changes => ["set ezjail_enable $rc_status"],
    }

    #variables
    $path_freebsd = ["/bin", "/sbin","/usr/bin", "/usr/sbin", "/usr/local/bin", "/usr/local/sbin"]
    #
    #Class for puppet
    package {"ezjail":
        ensure => installed,
        provider => pkgng,
    }

    #exec install ezjail
    $unless_test = $force_install ? {
        true  => '/bin/test',
        false => "/bin/test -d /usr/jails/basejail/bin",
    }

    exec {"ezjail-admin install":
        unless => $unless_test,
        path    => $path_freebsd,
    }


}

# vim: sts=4 ts=4 sw=4 expandtab autoindent
#
#INSTALL SKYPE ON DESKTOP
#
class puppet-ezjail ($force_install = false) {

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

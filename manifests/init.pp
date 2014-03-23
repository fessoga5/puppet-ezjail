# vim: sts=4 ts=4 sw=4 expandtab autoindent
#
#INSTALL SKYPE ON DESKTOP
#
class puppet-ezjail ($source, $destination = "/root/skype.deb") {
    #Class for puppet
    package {"ezjail-admin": 
        ensure => installed,
        providers => "ports",
    }
}

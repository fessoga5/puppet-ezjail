# vim: sts=4 ts=4 sw=4 expandtab autoindent
#
#INSTALL SKYPE ON DESKTOP
#
class puppet-ezjail {
    #Class for puppet
    package {"ezjail":
        ensure => installed,
        provider => pkgng,
    }
}

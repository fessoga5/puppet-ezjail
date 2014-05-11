puppet-ezjail
=============

puppet-ezjail


This is module for create jail host's on Freebsd using ezjail-admin. It create jail with vnet.

Example:
 
    #Install ezjail package
    class {"puppet-ezjail": enabled => true, }

    puppet-ezjail::jail {"file.rooml.ru":
        jail_name => "file_rooml_ru",
        jail_hostname => "file.rooml.ru",
        jail_rootdir => "/otp/jail",
        vnet_interface => "epair0",
        create => true,
        running => true,
        inet_epair_a => "172.16.100.1",
        netmask_epair_a => "255.255.255.252",
        jail_ipaddress => "172.16.100.2",
    }

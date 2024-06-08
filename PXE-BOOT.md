## How to configure TFTP, FTP, PXE boot for Harvester HCI Network Installation in VMware 8.x
### Environment
~~~
OS : Rocky Linux 9.x
IP : 192.168.0.90
~~~


### Install and Configure TFTP Server
- Package Installation and Enable Services
~~~
$ dnf install -y tftp-server tftp
$ cp /usr/lib/systemd/system/tftp.service /etc/systemd/system/tftp-server.service
$ cp /usr/lib/systemd/system/tftp.socket /etc/systemd/system/tftp-server.socket
~~~

- Configure Systemd Service
~~~
$ vi /etc/systemd/system/tftp-server.service

[Unit]
Description=Tftp Server
# Requires=tftp.socket
Requires=tftp-server.socket
Documentation=man:in.tftpd

[Service]
ExecStart=/usr/sbin/in.tftpd -s /var/lib/tftpboot
StandardInput=socket

[Install]
WantedBy=multi-user.target
Also=tftp.socket
~~~

- Configure Systemd Socket
~~~
$ vi /etc/systemd/system/tftp-server.socket
[Unit]
Description=Tftp Server Activation Socket

[Socket]
ListenDatagram=69
BindIPv6Only=both

[Install]
WantedBy=sockets.target
~~~

- Enable and Start TFTP Server
~~~
$ systemctl daemon-reload
$ systemctl enable tftp-server
$ systemctl start tftp-server
~~~

- Enable SELinux Policy
~~~
$ setsebool -P tftp_anon_write 1
$ setsebool -P tftp_home_dir 1
~~~

- Open TFTP in Firewalld
~~~
$ firewall-cmd --permanent --zone public --add-port 69/udp
$ firewall-cmd --permanent --zone public --add-port 69/tcp
$ firewall-cmd --reload
~~~


# Need to configure firewalld ruleset for dhcp,tftp,ftp and so on for specific devices in case of using bridge device for fedora 32

# Need test
# https://tecadmin.net/open-port-for-a-specific-network-in-firewalld/



~~~

[root@freeipa ~]# firewall-cmd --permanent --zone public --add-service tftp
[root@freeipa ~]# firewall-cmd --reload
[root@freeipa ~]# dnf install syslinux -y
[root@freeipa ~]# cp /usr/share/syslinux/menu.c32 /var/lib/tftpboot/
[root@freeipa ~]# cp /usr/share/syslinux/pxelinux.0 /var/lib/tftpboot/
[root@freeipa ~]# cp /usr/share/syslinux/ldlinux.c32 /var/lib/tftpboot/
[root@freeipa ~]# cp /usr/share/syslinux/libutil.c32 /var/lib/tftpboot/
[root@freeipa ~]# mkdir -p /var/lib/tftpboot/Linux/Weka/4.2
[root@freeipa ~]# mkdir /var/lib/tftpboot/pxelinux.cfg


[root@freeipa ~]# vi /var/lib/tftpboot/pxelinux.cfg/default

default menu.c32
prompt 0
timeout 60
ontimeout local

LABEL local
    MENU LABEL Boot Local Disk
    localboot 0

LABEL Weka 4.2
    MENU LABEL Weka 4.2 Kickstart Installation
    KERNEL /Linux/Weka/4.2/vmlinuz
    APPEND initrd=/Linux/Weka/4.2/initrd.img inst.repo=ftp://192.168.0.199/pub/Linux/Weka/4.2 inst.ks=ftp://192.168.0.199/pub/Linux/Weka/4.2/ks.cfg
~~~







[ FTP Server ]
~~~

[root@freeipa ~]# firewall-cmd --permanent --zone public --add-service ftp
[root@freeipa ~]# firewall-cmd --reload
[root@freeipa ~]# dnf install vsftpd -y

[root@freeipa ~]# vi /etc/vsftpd/vsftpd.conf
anonymous_enable=YES
local_enable=NO
write_enable=NO
local_umask=022
anon_upload_enable=NO
dirmessage_enable=YES
xferlog_enable=YES
connect_from_port_20=YES
xferlog_std_format=YES
listen=NO
listen_ipv6=YES
pam_service_name=vsftpd
userlist_enable=YES
anon_root=/ftp-root
no_anony_password=YES
chroot_local_user=YES
hide_ids=YES
local_root=/ftp-root

[root@freeipa ~]#  systemctl enable vsftpd

[root@freeipa ~]#  systemctl start vsftpd
~~~



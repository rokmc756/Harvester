## How to configure TFTP, FTP, PXE boot for Harvester HCI PXE Boot Network Installation in VMware 8.x
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
$ firewall-cmd --permanent --zone public --add-service tftp
$ firewall-cmd --reload
~~~

-  Need to configure firewalld ruleset for dhcp,tftp,ftp and so on for specific devices in case of using bridge device for fedora 32
-  Need test : https://tecadmin.net/open-port-for-a-specific-network-in-firewalld/


### Configure Syslinux
- Package Installation
~~~
$ dnf install syslinux -y
~~~

- Copy PXE Boot Menu and Utils
~~~
$ cp /usr/share/syslinux/menu.c32 /var/lib/tftpboot/
$ cp /usr/share/syslinux/pxelinux.0 /var/lib/tftpboot/
$ cp /usr/share/syslinux/ldlinux.c32 /var/lib/tftpboot/
$ cp /usr/share/syslinux/libutil.c32 /var/lib/tftpboot/
~~~

- Configure Boot Menu
~~~
$ mkdir -p /var/lib/tftpboot/Linux/Weka/4.2
$ mkdir /var/lib/tftpboot/pxelinux.cfg


$ vi /var/lib/tftpboot/pxelinux.cfg/default

default menu.c32
prompt 0
timeout 60
ontimeout local

LABEL local
    MENU LABEL Boot Local Disk
    localboot 0

LABEL SuSE Harvester HCI Master
    MENU LABEL SuSE Harvester HCI Master
    KERNEL /Linux/Harvester/1.2/harvester-v1.2.1-vmlinuz-amd64
    APPEND ip=dhcp net.ifnames=1 rd.cos.disable rd.noverifyssl console=tty1 initrd=/Linux/Harvester/1.2/harvester-v1.2.1-initrd-amd64 root=live:http://192.168.0.90:81/pub/Linux/Harvester/1.2/harvester-v1.2.1-rootfs-amd64.squashfs harvester.install.automatic=true harvester.install.config_url=http://192.168.0.90:81/pub/Linux/Harvester/1.2/config-create.yaml


LABEL SuSE Harvester HCI Worker 1st
    MENU LABEL SuSE Harvester HCI Worker 1st
    KERNEL /Linux/Harvester/1.2/harvester-v1.2.1-vmlinuz-amd64
    APPEND ip=dhcp net.ifnames=1 rd.cos.disable rd.noverifyssl console=tty1 initrd=/Linux/Harvester/1.2/harvester-v1.2.1-initrd-amd64 root=live:http://192.168.0.90:81/pub/Linux/Harvester/1.2/harvester-v1.2.1-rootfs-amd64.squashfs harvester.install.automatic=true harvester.install.config_url=http://192.168.0.90:81/pub/Linux/Harvester/1.2/config-join1.yaml


LABEL SuSE Harvester HCI Worker 2nd
    MENU LABEL SuSE Harvester HCI Worker 2nd
    KERNEL /Linux/Harvester/1.2/harvester-v1.2.1-vmlinuz-amd64
    APPEND ip=dhcp net.ifnames=1 rd.cos.disable rd.noverifyssl console=tty1 initrd=/Linux/Harvester/1.2/harvester-v1.2.1-initrd-amd64 root=live:http://192.168.0.90:81/pub/Linux/Harvester/1.2/harvester-v1.2.1-rootfs-amd64.squashfs harvester.install.automatic=true harvester.install.config_url=http://192.168.0.90:81/pub/Linux/Harvester/1.2/config-join2.yaml
~~~



### Configure FTP Server
- Configure Firewalld
~~~
$ firewall-cmd --permanent --zone public --add-service ftp
$ firewall-cmd --reload
~~

- Install and Configure VSFTPd
~~
$ dnf install vsftpd -y

$ vi /etc/vsftpd/vsftpd.conf
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
~~~

- Enable and Start VSFTPd
~~~
$  systemctl enable vsftpd
$  systemctl start vsftpd
~~~

### Configure NGINX Server
- Configure Firewalld
~~~
$ firewall-cmd --permanent --zone public --add-service http
$ firewall-cmd --reload
~~

- Install and Configure NGINIX
~~
$ dnf install nginx -y

$ vi /etc/nginx/nginx.conf
~~ snip
    server {
        listen       81;
        listen       [::]:81;
        server_name  _;
        root         /ftp-root;
        # root         /usr/share/nginx/html;
~~ snip
~~~

- Enable and Start NGINX
~~~
$  systemctl enable nginx
$  systemctl start nginx
~~~


### Download and Configure Harvester ISO and Boot Kernel for PXE Boot Network Installation
- Download Harvester ISO and Boot Kernel
~~~
wget https://releases.rancher.com/harvester/v1.2.1/harvester-v1.2.1-amd64.iso
wget https://releases.rancher.com/harvester/v1.2.1/harvester-v1.2.1-vmlinuz-amd64
wget https://releases.rancher.com/harvester/v1.2.1/harvester-v1.2.1-initrd-amd64
wget https://releases.rancher.com/harvester/v1.2.1/harvester-v1.2.1-rootfs-amd64.squashfs
~~~

- Locate Boot Kernel, Ramdisk and Rootfs into TFTP Root directory
~~~
$ mv /var/lib/tftpboot/Linux/Harvester/1.2/harvester-v1.2.1-vmlinuz-amd64
$ mv /var/lib/tftpboot/Linux/Harvester/1.2/harvester-v1.2.1-initrd-amd64
$ mv /var/lib/tftpboot/Linux/Harvester/1.2/harvester-v1.2.1-rootfs-amd64.squashfs
~~~

- Locate ISO to FTP or HTTP Root Directory
~~~
$ mv /ftp-root/pub/Linux/Harvester/1.2/harvester-v1.2.1-amd64.iso
or
$ mv /ftp-root/harvester-v1.2.1-amd64.iso
~~~

- Create directory for mounting Harvester ISO
~~~
$ mkdir /mnt/harvester

$ mount -o loop harvester-v1.2.1-amd64.iso /mnt/harvester/
mount: /mnt/harvester: WARNING: source write-protected, mounted read-only.

$ ls -al /mnt/harvester/
total 587101
drwxr-xr-x.  1 root root      2048 Oct 26  2023 .
drwxr-xr-x. 10 root root       118 Apr 29 16:57 ..
drwxr-xr-x.  1 root root      2048 Oct 26  2023 boot
drwxr-xr-x.  1 root root      2048 Oct 26  2023 bundle
drwxr-xr-x.  1 root root      2048 Dec 27  2022 EFI
-rw-r--r--.  1 root root       418 Oct 26  2023 harvester-release.yaml
-rw-r--r--.  1 root root 601182208 Oct 26  2023 rootfs.squashfs
~~~

- Configure Harvester Master Configuration for PXE Boot Installation
~~~
$ vi /ftp-root/pub/Linux/Harvester/1.2/config-create.yaml

scheme_version: 1
token: token # Replace with a desired token
os:
  hostname: sle15-hci-master # Set a hostname. This can be omitted if DHCP server offers hostnames
  ssh_authorized_keys:
    - ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCs7IgHTyaH3vGo0BDll/67ke83+YiADSwv8KvkQ4eBEBgYb1MI2jbVPBUOdYhf5QIpKv+MYFMOyWk1fkEJoxzZjjFPJ5AMhZW+yvBM6kqBQF6uy5WJ/ijRN0sHlsmRUtlUUeKyv5hwTDnH2EfBm0eWa0xfLUurtZLWiCkoRtaVdA3uH7eHDgoA+zloDIugLbvzGfTmGD27OJTJhgPS4LpR4wL/wg2zrzKqVUe/AIQCfzHy2o3qlmBYOtyJEtoVSsnpysUKcXaGRtWhMmI8FQ5seuxeuNyjtbuKUnhBeps4wVNJ1IB+vGMZwUGMB5WMOX/er5+rKvWJvzRSyoMhPz9R84TRjWjcRnsW93fZvolABp+tg23U/ARwPa63h9UHZmvmv3e0x83Pc2vR2iKL+zcj8AZ0Jm3hAfGq1a30VDpOrR0hhYcLvpP4ZADRv227bcWlydVTRy0NYnAngREm1WVO+17TEqkOIXbwRexWmN729dXO8JkwGH5CGE1b+6xD9BM= jomoon@LAPTOP-OS28E8H5
  password: changeme     # Replace with your password
  ntp_servers:
    - 0.suse.pool.ntp.org
    - 1.suse.pool.ntp.org
  dns_nameservers:
    - 192.168.0.90
    - 8.8.8.8
    - 168.126.63.1
install:
  mode: create
  management_interface: # available as of v1.1.0
    interfaces:
      - name: ens192
    default_route: true
    method: static
    ip: 192.168.0.191
    subnet_mask: 255.255.255.0
    gateway: 192.168.0.1
    mtu: 1500
  device: /dev/sda # The target disk to install
  iso_url: http://192.168.0.90:81/pub/Linux/Harvester/1.2/harvester-v1.2.1-amd64.iso
  vip: 192.168.0.190      # The VIP to access the Harvester GUI. Make sure the IP is free to use
  vip_mode: static        # Or dhcp, check configuration file for more information
~~~

- Configure Harvester Worker Node Configuration for PXE Boot Installation
~~~
$ vi /ftp-root/pub/Linux/Harvester/1.2/config-join1.yaml

scheme_version: 1
server_url: https://192.168.0.190:443  # Should be the VIP set up in "CREATE" config
token: token
os:
  hostname: sle15-hci-worker01
  ssh_authorized_keys:
    - ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCs7IgHTyaH3vGo0BDll/67ke83+YiADSwv8KvkQ4eBEBgYb1MI2jbVPBUOdYhf5QIpKv+MYFMOyWk1fkEJoxzZjjFPJ5AMhZW+yvBM6kqBQF6uy5WJ/ijRN0sHlsmRUtlUUeKyv5hwTDnH2EfBm0eWa0xfLUurtZLWiCkoRtaVdA3uH7eHDgoA+zloDIugLbvzGfTmGD27OJTJhgPS4LpR4wL/wg2zrzKqVUe/AIQCfzHy2o3qlmBYOtyJEtoVSsnpysUKcXaGRtWhMmI8FQ5seuxeuNyjtbuKUnhBeps4wVNJ1IB+vGMZwUGMB5WMOX/er5+rKvWJvzRSyoMhPz9R84TRjWjcRnsW93fZvolABp+tg23U/ARwPa63h9UHZmvmv3e0x83Pc2vR2iKL+zcj8AZ0Jm3hAfGq1a30VDpOrR0hhYcLvpP4ZADRv227bcWlydVTRy0NYnAngREm1WVO+17TEqkOIXbwRexWmN729dXO8JkwGH5CGE1b+6xD9BM= jomoon@LAPTOP-OS28E8H5
  password: changeme       # Replace with your password
  dns_nameservers:
    - 192.168.0.90
    - 192.168.0.100
    - 8.8.8.8
install:
  mode: join
  management_interface:    # available as of v1.1.0
    interfaces:
      - name: ens192
    default_route: true
    method: static
    ip: 192.168.0.192
    subnet_mask: 255.255.255.0
    gateway: 192.168.0.1
    mtu: 1500
  device: /dev/sda # The target disk to install
  iso_url: http://192.168.0.90:81/pub/Linux/Harvester/1.2/harvester-v1.2.1-amd64.iso
~~~


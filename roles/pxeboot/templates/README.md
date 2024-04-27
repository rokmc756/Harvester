
## Harvester FTP and HTTP Repository for PXE Boot
~~~
$ pwd
/ftp-root/pub/Linux/Harvester/1.2

$ ls

-rw-r--r--. 1 root   root         1740 Apr 27 18:30 config-create.yaml
-rw-r--r--. 1 root   root         1626 Apr 27 16:07 config-create.yaml.org
-rw-r--r--. 1 root   root         1480 Apr 27 18:36 config-join1.yaml
-rw-r--r--. 1 root   root         1476 Apr 27 18:37 config-join2.yaml
-rw-r--r--. 1 root   root         1430 Apr 27 16:33 config-join.yaml.org
-rwxrwxrwx. 1 jomoon jomoon 5497749504 Oct 26  2023 harvester-v1.2.1-amd64.iso
-rw-r--r--. 1 root   root     89153208 Oct 26  2023 harvester-v1.2.1-initrd-amd64
-rw-r--r--. 1 root   root    601182208 Oct 26  2023 harvester-v1.2.1-rootfs-amd64.squashfs
-rw-r--r--. 1 root   root     11477536 Oct 26  2023 harvester-v1.2.1-vmlinuz-amd64
-rw-r--r--. 1 root   root          366 Oct 26  2023 version.yaml
~~~


## Harvester TFTP Root Direcdtory for PXE Boot
~~~
$ pwd
/var/lib/tftpboot/pxelinux.cfg

$ vi default
default menu.c32
prompt 0
timeout 60
ontimeout local

LABEL local
    MENU LABEL Boot Local Disk
    localboot 0

LABEL Harvester Master
    MENU LABEL Harvester Master
    KERNEL /Linux/Harvester/1.2/harvester-v1.2.1-vmlinuz-amd64 ip=dhcp net.ifnames=1 rd.cos.disable rd.noverifyssl console=tty1
    APPEND initrd=/Linux/Harvester/1.2/harvester-v1.2.1-initrd-amd64 root=live:http://192.168.0.90:81/pub/Linux/Harvester/1.2/harvester-v1.2.1-rootfs-amd64.squashfs harvester.install.automatic=true harvester.install.config_url=http://192.168.0.90:81/pub/Linux/Harvester/1.2/config-create.yaml

LABEL Harvester Workers 1st
    MENU LABEL Harvester Workers 1st
    KERNEL /Linux/Harvester/1.2/harvester-v1.2.1-vmlinuz-amd64 ip=dhcp net.ifnames=1 rd.cos.disable rd.noverifyssl console=tty1
    APPEND initrd=/Linux/Harvester/1.2/harvester-v1.2.1-initrd-amd64 root=live:http://192.168.0.90:81/pub/Linux/Harvester/1.2/harvester-v1.2.1-rootfs-amd64.squashfs harvester.install.automatic=true harvester.install.config_url=http://192.168.0.90:81/pub/Linux/Harvester/1.2/config-join1.yaml

LABEL Harvester Workers 2nd
    MENU LABEL Harvester Workers 2nd
    KERNEL /Linux/Harvester/1.2/harvester-v1.2.1-vmlinuz-amd64 ip=dhcp net.ifnames=1 rd.cos.disable rd.noverifyssl console=tty1
    APPEND initrd=/Linux/Harvester/1.2/harvester-v1.2.1-initrd-amd64 root=live:http://192.168.0.90:81/pub/Linux/Harvester/1.2/harvester-v1.2.1-rootfs-amd64.squashfs harvester.install.automatic=true harvester.install.config_url=http://192.168.0.90:81/pub/Linux/Harvester/1.2/config-join2.yaml
~~~

## Harvester Download URL
~~~
https://releases.rancher.com/harvester/v1.2.1/harvester-v1.2.1-amd64.iso
https://releases.rancher.com/harvester/v1.2.1/harvester-v1.2.1-vmlinuz-amd64
https://releases.rancher.com/harvester/v1.2.1/harvester-v1.2.1-initrd-amd64
https://releases.rancher.com/harvester/v1.2.1/harvester-v1.2.1-rootfs-amd64.squashfs
https://releases.rancher.com/harvester/v1.2.1/harvester-v1.2.1-amd64.sha512
https://releases.rancher.com/harvester/v1.2.1/version.yaml
~~~



## What is Harvester?
Harvester is a modern hyperconverged infrastructure (HCI) solution built for bare metal servers using enterprise-grade open-source technologies
including Linux, KVM, Kubernetes, KubeVirt, and Longhorn. Designed for users looking for a flexible and affordable solution to run cloud-native
and virtual machine (VM) workloads in your datacenter and at the edge, Harvester provides a single pane of glass for virtualization and cloud-
native workload management.


## Why Harvester?
### Sits on the shoulders of cloud native giants
Harvester uses proven and mature open source software (OSS) components to build virtualization instead
of proprietary kernels that are kept hidden from view.

### Lower Total Cost of Ownership (TCO)
As 100% open source, Harvester is free from the costly license fees of other HCI solutions.
Plus, its foundation is based on existing technology such as Linux and kernel-based virtual machines.

### Integrate and prepare for the future
Built with cloud native components at its core, Harvester is future-proof as the infrastructure industry
shifts toward containers, edge and multi-cloud software engineering.


## Harvester Architecture
![alt text](https://github.com/rokmc756/Harvester/blob/main/roles/harvester/files/harvester-arch-update-grey.png)

## Harvester Cluster Network Diagram
![alt text](https://github.com/rokmc756/Harvester/blob/main/roles/harvester/files/harvester-traffic-isolation.png)

## Relationship Between Harvester Cluster Network, Network Config, VM Network
![alt text](https://github.com/rokmc756/Harvester/blob/main/roles/harvester/files/harvester-relation.png)

## Harvester Network Deep Dive
![alt text](https://github.com/rokmc756/Harvester/blob/main/roles/harvester/files/harvester-topology.png)




## PXE Boot and Configuraion

https://www.suse.com/c/rancher_blog/harvester-intro-and-setup/
https://github.com/harvester/harvester-installer
https://docs.harvesterhci.io/v1.2/install/pxe-boot-install/
https://docs.harvesterhci.io/v1.1/install/harvester-configuration/

## Hosted (Nested) VM
https://kb.vmware.com/s/article/1008443
https://www.server-world.info/en/note?os=ESXi_8&p=vm&f=4

## ESXi USB Keyboard (HID) Passthrough
* https://www.youtube.com/watch?v=-obzzQzfmHA
* https://williamlam.com/2020/05/how-to-passthrough-usb-keyboard-mouse-hid-and-ccid-devices-to-vm-in-esxi.html

## Download URL
https://releases.rancher.com/harvester/v1.2.1/harvester-v1.2.1-amd64.iso
https://releases.rancher.com/harvester/v1.2.1/harvester-v1.2.1-vmlinuz-amd64
https://releases.rancher.com/harvester/v1.2.1/harvester-v1.2.1-initrd-amd64
https://releases.rancher.com/harvester/v1.2.1/harvester-v1.2.1-rootfs-amd64.squashfs
https://releases.rancher.com/harvester/v1.2.1/harvester-v1.2.1-amd64.sha512
https://releases.rancher.com/harvester/v1.2.1/version.yaml


## Image URL
https://registry.terraform.io/providers/harvester/harvester/latest/docs/resources/image


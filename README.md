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
- All Network Configs and VM Networks are grouped under a cluster network.

- A label can be assigned to each host to categorize hosts based on their network specifications.
- A network config can be added for each group of hosts using a node selector.
- For example, in the diagram above, the hosts in ClusterNetwork-A are divided into three groups as follows:
~~~
The first group includes host0, which corresponds to network-config-A.
The second group includes host1 and host2, which correspond to network-config-B.
The third group includes the remaining hosts (host3, host4, and host5), which do not have any related network config and therefore do not belong to ClusterNetwork-A.
The cluster network is only effective on hosts that are covered by the network configuration. A VM using a VM network under a specific cluster network can only be scheduled on a host where the cluster network is active.
~~~

- In the diagram above, we can see that:
~~~
ClusterNetwork-A is active on host0, host1, and host2. VM0 uses VM-network-A, so it can be scheduled on any of these hosts.
VM1 uses both VM-network-B and VM-network-C, so it can only be scheduled on host2 where both ClusterNetwork-A and ClusterNetwork-B are active.
VM0, VM1, and VM2 cannot run on host3 where the two cluster networks are inactive.
Overall, this diagram provides a clear visualization of the relationship between cluster networks, network configurations, and VM networks, as well as how they impact VM scheduling on hosts.
~~~


## Harvester Network Deep Dive
![alt text](https://github.com/rokmc756/Harvester/blob/main/roles/harvester/files/harvester-topology.png)
### KubeVirt Networking
- The general purpose of KubeVirt is to run VM inside the Kubernetes pod. The KubeVirt network builds the network path between the pod and VM. Please refer to the KubeVirt official document for more details.

### Harvester Networking
- Harvester networking is designed to build the network path between pods and the host network. It implements a management network, VLAN networks and untagged networks. We can refer to the last two networks as bridge networks, because bridge plays a vital role in their implementation.

### Bridge Network
- We leverage multus CNI and bridge CNI to implement the bridge network. Multus CNI is a Container Network Interface (CNI) plugin for Kubernetes that can attach multiple network interfaces to a pod. Its capability allows a VM to have one NIC for the management network and multiple NICs for the bridge network. Using the bridge CNI, the VM pod will be plugged into the L2 bridge specified in the Network Attachment Definition config.
~~~
# Example 1
{
    "cniVersion": "0.3.1",
    "name": "vlan100",
    "type": "bridge",
    "bridge": "mgmt-br",
    "promiscMode": true,
    "vlan": 100,
}

# Example 2
{
    "cniVersion": "0.3.1",
    "name": "untagged-network",
    "type": "bridge",
    "bridge": "oob-br",
    "promiscMode": true,
    "ipam": {}
}
~~~
Example 1 is a typical VLAN configuration with VLAN ID 100, while Example 2 is an untagged network configuration with no VLAN ID. The VM pod configured using Example 1 will be plugged into the bridge mgmt-br, while the VM pod using Example 2 will be plugged into the bridge oob-br.
To achieve high availability and fault tolerance, a bond device where the real NICs are bound is created to serve as the uplink of the bridge. By default, this bond device will allow the target tagged traffic/packets to pass through.
~~~
harvester-0:/home/rancher # bridge -c vlan show dev oob-bo
port       vlan ids
oob-bo     1 PVID Egress Untagged
           100
           200
~~~

The example above shows that the bond oob-bo allows packages with tag 1, 100 or 200.

### Management Network
- The management network is based on Canal. It is worth mentioning that the Canal interface where the Harvester configures the node IP is the bridge mgmt-br or a VLAN sub-interface of mgmt-br. This design has two benefits:
- The built-in mgmt cluster network supports both the management network and bridge network. With the VLAN network interface, we can assign a VLAN ID to the management network. As components of the mgmt cluster network, it's not allowed to delete or modify the bridge mgmt-br, the bond mgmt-bo and the VLAN device.

### External Networking
- External network devices typically refer to switches and DHCP servers. With a cluster network, we can group host NICs and connect them to different switches for traffic isolation. Below are some usage instructions.
- To allow tagged packets to pass, you need to set the port type of the external switch or other devices (such as a DHCP server) to trunk or hybrid mode and allow the specified VLAN tag.
- You need to configure link aggregation on the switch based on the bond mode of the peer host. Link aggregation can work in manual mode or LACP mode. The following lists the correspondence between bond mode and link aggregation mode.
~~~
Bond Mode	Link Aggregation Mode
mode 0(balance-rr)	manual
mode 1(active-backup)	none
mdoe 2(balance-oxr)	manual
mode 3(broadcast)	manual
mode 4(802.3ad)	LACP
mode 5(balance-tlb)	none
mode 6(balance-alb)	none
~~~
- If you want VMs in a VLAN to be able to obtain IP addresses through the DHCP protocol, configure an IP pool for that VLAN in the DHCP server.



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


# Google Anthos Clusters on Bare Metal Manual Installation on Nutanix AHV

Note: The following Google Anthos versions have been tested on Nutanix AHV:

|Google Anthos versions       |
|-----------------------------|
|1.6.x - 1.9.x, 1.13.x, 1.14.x|


When installing Google Anthos clusters on bare metal on Nutanix AHV, it is required to manually [create the virtual machines through Prism Central](https://portal.nutanix.com/page/documents/details?targetId=Prism-Central-Guide-vpc_2022_9:mul-vm-create-acropolis-pc-t.html){target=_blank}. 

These virtual machines need to run a validated operating system. The list of validated operating systems can be found in the Nutanix section of the [partner platforms](https://cloud.google.com/anthos/docs/resources/partner-platforms#nutanix){target=_blank} page.

Google Anthos clusters on bare metal requires the following virtual machines types to be provisioned:

- Admin workstation (see [admin workstation prerequisites](https://cloud.google.com/anthos/clusters/docs/bare-metal/latest/installing/workstation-prerequisites){target=_blank})
- Cluster nodes (see [cluster node machine prerequisites](https://cloud.google.com/anthos/clusters/docs/bare-metal/latest/installing/node-machine-prerequisites){target=_blank})

!!! note
    The number of cluster node virtual machines that need to be created depend on the [deployment type for the controlplane](https://cloud.google.com/anthos/clusters/docs/bare-metal/latest/installing/install-prep#high_availability){target=_blank} and the amount of worker nodes required for the application.



Refer to the [Anthos clusters on bare metal quickstart](https://cloud.google.com/anthos/clusters/docs/bare-metal/latest/quickstart){target=_blank} to get a detailed overview of the installation procedure of Google Anthos. 

!!! note
    When deploying the Anthos nodes on a Nutanix IPAM-managed subnet, make sure the `controlPlaneVIP`, `ingressVIP` and `addressPools` are not part of one of the IP-pools to prevent IP conflicts. 


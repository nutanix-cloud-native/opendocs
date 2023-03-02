---
title: "Assisted Installation (UPI)"
---

# OCP: Assisted Installation (UPI)

!!!note "Nutanix AOS, Prism Central and Openshift Compatibility"
         
         Red Hat OpenShift container platform has been tested for specific compatibility on following AOS and Prism Central versions:

         | Openshift | AOS              | Prism Central |
         |:-----------:|:-------------------:|:---------------:|
         | 4.12      | 5.20.4+ or 6.5.1+ | 2022.4+       |
         | 4.11      | 5.20.4+ or 6.1.1+ | 2022.4+       |

Assisted installation works with User Provisioned Infrastructure(UPI). 

An administrator will need to provision all the infrastructure related components and Assisted Installation process can used provision a OpenShift Kubernetes cluster. 

This offers quite a few options for customising the following(not limited to):

- Virtual Machines 
  - CPU, memory, networking and storage
- General networking services - DNS and DHCP services
- Security services - firewall
- Placement of resources in different locations (where supported by OpenShift)
- IDP services - Active Directory, LDAP, etc.

Once the infrastructure components are provisioned and ready for use, Assisted Installation process can take over and deploy a OpenShift Kubernetes cluster.
  
## Pre-requisites for Assisted Installation

- Access to [Red Hat Console](https://console.redhat.com/) (portal) to use Assisted Installer and install a OpenShift Kubernetes cluster, add extra OpenShift nodes (at a later time), etc.
-   OCP Master and Worker virtual machines on Nutanix HCI platform created by the administrator
-   Compute, networking and storage associated with the OCP Master and Worker VMs provisioned by the administrator
-   DNS and DHCP server in the environment
-   A SSH key pair for the OCP Master and Worker virtual machines

    <details>
    <summary>Steps to create a ssh key pair</summary>
    <div>
    <body>
    Execute the following commands and keep the key pair somewhere safe.
    
    ```bash
    ssh-keygen -t rsa -b 2048 -f ~/.ssh/
    
    # follow prompts 
    # once completed run the following command
    ```
    ```bash
    cat ~/.ssh/id_rsa.pub

    # copy the contents of the id_rsa.pub file to your Add hosts SSH public key section
    ```
    </body>
    </div>
    </details> 

    
-   Two static IPs for Openshift Kubernetes cluster's API and network Ingress endpoints
    
    !!!warning
              Do not proceed with installation unless you have reserved two IPs for these endpoints. There is a chance of the AHV IPAM network distributing these IPs if not reserved.
  
    <details>
    <summary>Steps to find and reserve two static IPs in AHV network</summary>
    <div>
    <body>
    
    Get the CIDR for your AHV Network

       ```bash title="CIDR example for your AHV network"
       10.38.18.192/26
       ```
    
    Find two unused static IP addresses using the following commands and reserve them for API and Ingress endpoints.
       
    === "Template command"

        ```bash
        nmap -v -sn  <your CIDR>
        ```
    === "Sample command"

        ```bash
        nmap -v -sn 10.38.18.192/26
        ```

       ```bash hl_lines="1 2" title="Sample output - choose the first two consecutive IPs"
       Nmap scan report for 10.38.18.219 [host down] 
       Nmap scan report for 10.38.18.220 [host down]
       Nmap scan report for 10.38.18.221
       ```
    
    SSH to any CVM in your cluster and execute the following to **exclude** it from DHCP distribution
    
       - Username: nutanix
       - Password: your cvm password 
  
    === "Template command"

        ```bash
        acli net.add_to_ip_blacklist <your-ipam-ahv-network> ip_list=<API IP and Ingress IP addresses>
        ```
    === "Sample command"

        ```bash
        acli net.add_to_ip_blacklist Primary ip_list=10.38.18.219,10.38.18.220
        ```
    </body>
    </div>
    </details>

- Add reserved static IPs to your environment's DNS server for the API and Ingress endpoints
  
    <details>
    <summary>Steps to add DNS server - Windows DNS server example</summary>
    <div>
    <body>
    
    We will add PC, API and APPS Ingress DNS records for lookup by OCP IPI installer.

    Your OCP cluster's name becomes a subdomain in your DNS zone ``ntnxlab.local``. All OCP cluster related lookups are located within subdomain.
    
    - Main domain -  ``ntnxlab.local`` (this gets created with your HPOC reservation)
      - Sub domain - ``xyz.ntnxlab.local`` (xyz is your OCP cluster's name)
    
    1. Logon to your environment's Windows DNS server
    
    2. We will add the following entries to DNS server using the two consecutive IPs you found in the previous section
       
        ```buttonless
        10.38.18.219   api.your_ocp_cluster_subdomain.ntnxlab.local
        10.38.18.220   *.apps.your_ocp_cluster_subdomain.ntnxlab.local
        ```
        
        !!!warning
                  Use IP addresses from your Nutanix cluster's CIDR.
              
                  The IP addresses in the following commands are used as an example. You should use IP address details that belong to your HPOC cluster. For information on locating your cluster IP see Getting Started [Networking](../intro.md#networking) section. 
  
    3. Open PowerShell as Administrator and create the two A records
       
        === "Command template"
 
            ```PowerShell title="Add the API A record - use your own subdomain"
            Add-DnsServerResourceRecordA -Name api.<your_ocp_cluster_subdomain> -IPv4Address <your API IP> -ZoneName ntnxlab.local -ZoneScope ntnxlab.local
            ```
            ```PowerShell title="Add the apps Ingress A record - use your own subdomain"
            Add-DnsServerResourceRecordA -Name *.apps.<your_ocp_cluster_subdomain> -IPv4Address <your Ingress IP> -ZoneName ntnxlab.local -ZoneScope ntnxlab.local 
            ```
            ```PowerShell title="Add the Prism Central A record"
            Add-DnsServerResourceRecordA -Name pc -IPv4Address <your PC IP> -ZoneName ntnxlab.local -ZoneScope ntnxlab.local 
            ```
        === "Command example"
 
        ```PowerShell title="Sample commands with 'xyz' as a subdomain and your OCP cluster name"
        Add-DnsServerResourceRecordA -Name api.xyz -IPv4Address 10.38.18.219 -ZoneName ntnxlab.local -ZoneScope ntnxlab.local
        Add-DnsServerResourceRecordA -Name *.apps.xyz -IPv4Address 10.38.18.220 -ZoneName ntnxlab.local -ZoneScope ntnxlab.local 
        Add-DnsServerResourceRecordA -Name pc -IPv4Address 10.38.18.201 -ZoneName ntnxlab.local -ZoneScope ntnxlab.local
        ```
    
    4. Test name resolution for added entries
    
        ```PowerShell hl_lines="6 13 20"
        nslookup api.xyz.ntnxlab.local
        Server: dc.ntnxlab.local
        Address: 10.38.18.203
     
        Name: api.xyz.ntnxlab.local
        Address: 10.38.18.219 
        #
        nslookup myapp.apps.xyz.ntnxlab.local
        Server: dc.ntnxlab.local
        Address: 10.38.18.203
     
        Name: myapp.apps.xyz.ntnxlab.local
        Address: 10.38.18.220
        #
        nslookup pc.ntnxlab.local
        Server: dc.ntnxlab.local
        Address: 10.38.18.203
     
        Name: pc.ntnxlab.local
        Address: 10.38.3.201
        ```
    </body>
    </div>
    </details>

## Overview of Assisted Installation Process

Assisted Installer does the following:

-   Provides RHCOS and OCP installation binaries in a CD-ROM ISO file
-   Once the OCP VMs (Master and Worker) nodes are booted with this CD-ROM ISO file, using the SSH public key the VMs connect to Red Hat Console
-   VMs show in Assisted Installer page (Red Hat Console) and the administrator begins the installation process
-   Assisted installer will choose one of the Master VMs to serve the Bootstrap role during cluster installation
-   Red Hat Console will manage and monitor the installation process from start to finish
-   Upon successful installation of a OCP cluster the following will be
    provided:
    -   KUBECONFIG file for `oc` command line access
    -   Configurable DNS entries for OCP Cluster access inside your networking environment


!!!info "About Assisted Installer"

       Assisted Installer feature is in GA [General Availability](https://cloud.redhat.com/blog/openshift-assisted-installer-is-now-generally-available) as of July 2022. 
       
       The OCP clusters deployed using Assisted Installers can be used for production, testing and development purposes conforming to these [pre-requisites](https://cloud.redhat.com/blog/using-the-openshift-assisted-installer-service-to-deploy-an-openshift-cluster-on-metal-and-vsphere#:~:text=Pre%2Drequisites,required%20for%20accessing%20the%20cluster).


### High Level Installation Steps 

At a high level, we will do the following to get a OCP cluster deployed using Assisted Installer:

1.  Provision OCP Cluster in Red Hat Console
2.  Generate CD-ROM ISO URL
3.  Provision OCP Infrastructure - Create Master and Worker VMs in your
4.  Nutanix AHV cluster using Terraform infrastructure as code
5.  Install OCP Cluster from Red Hat Console (portal)

## Provision OCP Cluster in Red Hat Console

1.  Go to [Red Hat Console](https://console.redhat.com/openshift/assisted-installer/clusters)
   
2.  Login using your Red Hat Console portal's credentials

3.  Click on **Create New Cluster**

4.  Fill in the following details:

    -   **Cluster name** - Initials-assisted-cluster (e.g. xyz-assisted-cluster)
    -   **Base domain** - yourdomain.com (e.g. ntnxlab.local)
    -   **OpenShift version** - choose the version from drop-down (e.g OpenShift 4.12.4)
    -   **CPU architecture** - x86_64
    -   **Hosts' network configuration** - DHCP only 

5.  Click on **Next**

6.  Click Next on **Operators** page - do not select any options

7.  Click on **Add Host**

8.  In the **Add Host** pop-up window select **Minimal image file: Provision with virtual media**

9.  In the **SSH public key** text box provide the public key you created in this [pre-requisites section](../assisted/index.md#pre-requisites-for-assisted-installation).
    
    !!!warning
    
            Make sure to copy the contents of **public key** (id_ras.pub) and paste it

            You can also use the **Browse** option in the wizard to select the id_ras.pub file

    ![](images/ocp_public_key.png)
   
10. Click on **Generate Discovery ISO**

11. Copy the **Discovery ISO URL** and note it down somewhere. You will
    need this for your next section while creating infrastructure.

    ![](images/ocp_iso_url.png)

12. Click on **Close**

## Provision OCP Infrastructure

In this section we will create all infrastructure components for the OpenShift cluster. 

You are able to create these VMs and its resources using the Prism Element GUI. But in this section we will use **Terraform** code for repeatability and ease. Nutanix provides Terraform integration for managing the entire lifecycle of Nutanix resources (virtual machines, networks, etc). See [Terraform Nutanix Provider](https://github.com/nutanix/terraform-provider-nutanix) for details. 

We will create the following minimum required resources in prepartion for our OpenShift cluster:
  
| OCP Role   |    Operating System    |    vCPU    |  RAM         | Storage   | IOPS |           
| -------------|  ---------------------- |  -------- | ----------- |  --------- |  -------- | 
| Bootstrap    |  RHCOS                 |  4       |  16 GB       | 100 GB    | 300 | 
| Master       |  RHCOS                 |  4        | 16 GB      |  100 GB   |  300 | 
| Worker       |  RHCOS               |  8  |  16 GB      |  100 GB |    300 | 

For latest resource requirements of an OpenShift cluster refer to [OpenShift portal](https://docs.openshift.com/container-platform/4.9/installing/installing_platform_agnostic/installing-platform-agnostic.html#installation-minimum-resource-requirements_installing-platform-agnostic)

1.  Login to your workstation

2.  Run the following command to install Terraform on your workstation

    === "Mac"

        ```bash
        brew tap hashicorp/tap
        brew install hashicorp/tap/terraform
        ```

    === "Windows"

        ```PowerShell
        choco install terraform
        ```
    
    === "CentOS"
        
        ```bash
        yum update -y 
        yum install -y yum-utils
        yum-config-manager --add-repo https://rpm.releases.hashicorp.com/RHEL/hashicorp.repo
        yum -y install terraform
        yum -y install git
        ```


3.  Clone the following git repo and initialise Terraform provider

    ```bash
    git clone https://github.com/nutanix-japan/tf-ocp-infra
    cd tf-ocp-infra
    alias "tf=terraform" 
    tf init
    ```

4.  Get your variables file ready with your Nutanix AHV environment
    information

    ```bash
    cp terraform.tfvars.sample terraform.tfvars
    ```

5.  Modify your variables to suit your Nutanix environment

    ``` bash
    vi terraform.tfvars
    ```
    
    === "Template file"

        ```bash
        cluster_name        = "your cluster name" # << Change this
        subnet_name         = "your AHV network"  # << Change this
        user                = "admin"             # << Change this
        password            = "XXXXXXX"           # << Change this
        endpoint            = "Prism Element IP"  # << Change this
        vm_worker_prefix    = "xyz-worker"        # << Change xyz to your initials
        vm_master_prefix    = "xyz-master"        # << Change xyz to your initials
        vm_domain           = "yourdomain.com"    # << Change xyz to your initials
        vm_master_count     = 3
        vm_worker_count     = 2
        image_uri           = "Discover ISO URL you copied earlier" # << Change this
        ```

    === "Example file"

        ```bash
        cluster_name        = "my-pe-cluster"          
        subnet_name         = "Primary"
        user                = "admin"            
        password            = "mypepassword"           
        endpoint            = "10.55.64.100"          
        vm_worker_prefix    = "xyz-worker"            
        vm_master_prefix    = "xyz-master"         
        vm_domain           = "ntnxlab.local"
        vm_master_count     = 3
        vm_worker_count     = 2
        image_uri           = "https://api.openshift.com/api/assisted-images/images/fff332e9-abc1-42d1-b9e4-60ce81a914bf?arch=x86_64&image_token=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJleHAiOjE2Nzc3NDIzNjEsInN1YiI6ImZmZjMzMmU5LWFiYzEtNDJkMS1iOWU0LTYwY2U4MWE5MTRiZiJ9.w5uPr2yxw2Vk1ZbeIdOlvaAqDOY0TliuMQUX1j0fTLo&type=minimal-iso&version=4.12" 
        ```

6.  Validate your Terraform code

    ```bash
    tf validate
    ```

7.  Apply your Terraform code to create virtual machines and associated resources
  
    ```bash
    tf apply 

    # Terraform will show you all resources that it will to create
    # Type yes to confirm 
    ```

    ``` bash
    # Sample output for the command above

    Terraform will perform the actions described above.
    Only 'yes' will be accepted to approve.

    Enter a value: yes

    nutanix_image.RHCOS: Creating...
    nutanix_image.RHCOS: Still creating... [10s elapsed]
    nutanix_image.RHCOS: Creation complete after 14s [id=e04cff4e-a6cf-45f9-890d-96097c4b53ed]
    nutanix_virtual_machine.RHCOS-master[0]: Creating...
    nutanix_virtual_machine.RHCOS-master[1]: Creating...
    nutanix_virtual_machine.RHCOS-worker[0]: Creating...
    nutanix_virtual_machine.RHCOS-master[2]: Creating...
    nutanix_virtual_machine.RHCOS-worker[1]: Creating...
    nutanix_virtual_machine.RHCOS-master[0]: Still creating... [10s elapsed]
    nutanix_virtual_machine.RHCOS-master[1]: Still creating... [10s elapsed]
    nutanix_virtual_machine.RHCOS-master[2]: Still creating... [10s elapsed]
    nutanix_virtual_machine.RHCOS-worker[0]: Still creating... [10s elapsed]
    nutanix_virtual_machine.RHCOS-worker[1]: Still creating... [10s elapsed]
    nutanix_virtual_machine.RHCOS-master[0]: Creation complete after 16s [id=3a88a3d7-304e-4284-886d-f7882764d7cc]
    nutanix_virtual_machine.RHCOS-master[2]: Creation complete after 17s [id=5e87599a-5643-465d-9870-5b34751b2158]
    nutanix_virtual_machine.RHCOS-worker[0]: Creation complete after 17s [id=78fb2e69-fee7-4244-ae5c-55ffbc1da21d]
    nutanix_virtual_machine.RHCOS-master[1]: Creation complete after 17s [id=7775b527-fc55-4cac-aabc-a024ea4938c1]
    nutanix_virtual_machine.RHCOS-worker[1]: Creation complete after 17s [id=c9801a82-a7e3-444e-a206-d5e3e3a75bb1]

    Apply complete! Resources: 6 added, 0 changed, 0 destroyed.
    ```

8.  Run the Terraform state list command to verify what resources have been created

    ``` bash
    tf state list
    ```

    ``` bash
    # Sample output for the above command

    data.nutanix_cluster.cluster            # < This is your existing Prism Element cluster
    data.nutanix_subnet.subnet              # < This is your existing Primary subnet
    nutanix_image.RHCOS                     # < This is OCP Discovery ISO image
    nutanix_virtual_machine.RHCOS-master[0] # < This is master vm 1
    nutanix_virtual_machine.RHCOS-master[1] # < This is master vm 2
    nutanix_virtual_machine.RHCOS-master[2] # < This is master vm 3
    nutanix_virtual_machine.RHCOS-worker[0] # < This is worker vm 1
    nutanix_virtual_machine.RHCOS-worker[1] # < This is worker vm 2
    ```

9.  Login to **Prism Element** > **VM** and verify the VMs and if they are powered on

    ![](images/ocp_tf_vms.png)

## Install OCP Cluster in Red Hat Console

In this section we will use Red Hat Console's Assisted Installer wizard to install the OCP cluster with the VMs we have provisioned.

1.  Return to Red Hat Openshift Console and check if the VMs appear
    (this may take up to 5 minutes)

    ![](images/ocp_rh_console_vms.png)

2.  Click **Next** at the bottom of the page

3.  In the Networking section, assign IPs for your **API Virtual IP** and **Ingress Virtual IP** from your AHV network CIDR range 

4.  In the **Host inventory** section, choose the **Control Plane Node** for Master VMs and **Worker** nodes for Worker VMs from the drop-down menu

    ![](images/ocp_node_roles.png)

5.  Click **Next** at the bottom of the page

6.  Review your setup information and click on **Install Cluster**

    ![](images/ocp_cluster_summary.png)

7.  You will be taken to monitoring your installation progress

    ![](images/ocp_install_start.png)

    Now the cluster deploy will proceed

8.  Watch for any messages about user interactions in the progress page

    ![](images/ocp_user_inter.png)

9.  This message is wanting the user to unmount the installation Discovery ISO so they VM can boot into the OS drive

10. Go to **Prism Element** > **VM** > **Master/Worker VM** > **update**

11. Under Disks > Click on Eject

    ![](images/pe_vm_cd_eject.png)

12. Click on Save

13. Under **Power Off Actions** choose to Guest Reboot the VM where there are pending user action

14. Repeat ejecting CD-ROM for all VMs and rebooting it as the Wizard prompts for user action (do not do this before the prompting)

15. Once all the user actions are sustained for Master and Worker VMs, OCP cluster will be installed

    ![](images/ocp_install_finish.png)

### Access to your OpenShift Cluster

Create DNS entries in your environment to be able to access the OpenShift cluster.

- On your workstation - using ``/etc/hosts`` file

- On your network - creating entries in a DNS server (see [pre-requisites](../assisted/index.md#pre-requisites-for-assisted-installation))

The Installation wizard gives you DNS entries for your workstation as well as a centralised DNS server.

![](images/ocp_access.png)

Click on **Not able to access Web Console?** link in the status page to reveal IP addresses and DNS entry suggestions.

![](images/ocp_dns_hosts.png)


Once you have done creating DNS entries, you can access OpenShift cluster in two ways:

1. Using ``oc`` or ``kubectl`` commands 
   
    Download the kubeconfig file from the installation page of the Red Hat portal to your workstation
 
    ```bash title="Change access mode for security"
    chmod 400 kubeconfig
    ```
    ```bash title="Export kubeconfig to PATH"
    export KUBECONFIG=/path/to/kubeconfig
    ```
    ```bash title="Execute oc commands to confirm"
    oc get nodes
    ```
   
2. Using the OpenShift Clusters Web UI: 

    You can access your installed OCP Cluster Manger page using the URL provided in the Installation progress screen of Red Hat portal.
    
    !!!warning
 
              This URL can **only** be accessed within your network environment unless you expose it outside your private CIDR range.
 
    ![](images/ocp_console_ai.png)


## Takeaways

-   You can easily deploy multinode/single node OCP cluster using the Red Hat console
-   You can provision resources (VM, Storage, etc) on Nutanix using Terraform IaaC (GitOps)
    
    !!!info "Good to know"

          The Installer Provisioned Installer (IPI) also uses Terraform to deploy infrastructure assets (VM) on Nutanix and VMware

-   Assisted Installer provisioned OCP clusters can be used as a learning ground and for testing purposes
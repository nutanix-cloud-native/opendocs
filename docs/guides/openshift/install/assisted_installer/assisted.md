---
title: "Assisted Installer"
---
# Assisted Installer

!!!note "Nutanix AOS, Prism Central and Openshift Compatibility"
         
         Red Hat OpenShift Container Platform Assisted Installer has been tested for specific compatibility on following AOS and Prism Central versions:

         | Openshift | AOS              | Prism Central |
         |:-----------:|:-------------------:|:---------------:|
         | 4.12      | 5.20.4+ or 6.5.1+ | 2022.4+       |

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
-  AHV Network - configured with DNS and DHCP pool in the environment
-   A SSH key pair for the OCP Master and Worker virtual machines

    ???info "Optional steps to create a SSH key pair"
           
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

    
-   Find and reserve two static IPs for Openshift Kubernetes cluster's ``API`` and network ``Ingress`` endpoints in the same CIDR as your yet to be installed OCP kubernetes master and worker VMs. 
    
    !!!warning
              Make sure to exclude the assigned IPs for ``API`` and network ``Ingress`` endpoints from any DHCP server's scope. 
   
              Do not proceed with installation unless you have made sure that none of the DHCP servers in your environment is distributing these IPs. 
   
- Add reserved static IPs to your environment's DNS server for the API and Ingress endpoints

    ???info "Steps to add DNS entries for API and Ingress Endpoints"

        We will add API and APPS Ingress DNS records for lookup by OCP IPI installer.

        Export two reserved IPs to your workstation's environment variables to use with ``API`` and ``Ingress`` 
        endpoints.

        ```bash
        export API_IP="x.x.x.x"
        export INGRESS_IP="x.x.x.x"
        ```
        
        Your OCP cluster's name becomes a subdomain in your DNS zone ``example.com``. All OCP cluster related lookups are located within subdomain.
        
        - Main domain -  ``example.com``  (can be any domain name but needs to be existing and contactable)
        - Sub domain - ``ocp-cluster.example.com`` ( ``ocp-cluster`` is your OCP cluster's name)
        
        In your environment's DNS server, configure the following DNS entries using the two consecutive IPs you found in the previous section: 

        **Take care to enter the actual IP address as the environment variables will not be available in your DNS server. It is only mentioned here for documentation purposes.**
        
        - One ``A`` record DNS entry for OCP Kubernetes cluster's API
        
            ``` { .text .no-copy }
            ${API_IP} == api.ocp-cluster.example.com
            ```
        
        - One wildcard ``A`` record DNS entry for the OCP cluster's Ingress 
        
            ``` { .text .no-copy }
            ${INGRESS_IP} == *.ocp-cluster.example.com
            ```
        

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
    -   Configurable DNS entries for OCP Cluster access


!!!info "About Assisted Installer"

       Assisted Installer feature is in GA [General Availability](https://cloud.redhat.com/blog/openshift-assisted-installer-is-now-generally-available) as of July 2022. 
       
       The OCP clusters deployed using Assisted Installers can be used for production, testing and development purposes conforming to these [pre-requisites](https://cloud.redhat.com/blog/using-the-openshift-assisted-installer-service-to-deploy-an-openshift-cluster-on-metal-and-vsphere#:~:text=Pre%2Drequisites,required%20for%20accessing%20the%20cluster).


### High Level Installation Steps 

At a high level, we will do the following to get a OCP cluster deployed using Assisted Installer:

1.  Provision OCP Cluster in Red Hat Console
2.  Generate CD-ROM ISO URL
3.  Provision OCP Infrastructure - Create Master and Worker VMs in your Nutanix cluster
4.  Nutanix AHV cluster using Terraform infrastructure as code
5.  Install OCP Cluster from Red Hat Console (portal)

## Provision OCP Cluster in Red Hat Console

1.  Go to [Red Hat Console](https://console.redhat.com/openshift/assisted-installer/clusters)
   
2.  Login using your Red Hat Console portal's credentials

3.  Click on **OpenShift**

4.  Click on **Datacenter** tab 
   
5.  Under Assisted Installer, click on **Create Cluster**

6.  Fill in the following details:

    -   **Cluster name** - ocp-cluster 
    -   **Base domain** - example.com
    -   **OpenShift version** - choose the version from drop-down (e.g OpenShift 4.12.9)
    -   **CPU architecture** - x86_64
    -   **Hosts' network configuration** - DHCP only 

7.  Click on **Next**

8.  Click Next on **Operators** page - do not select any options

9.  Click on **Add Host**

10. In the **Add Host** pop-up window select **Minimal image file: Provision with virtual media**

11. In the **SSH public key** text box provide the public key you created in this [pre-requisites](#pre-requisites-for-assisted-installation) section
    
    !!!warning
    
            Make sure to copy the contents of the **public key** (id_ras.pub) file that you created (or any public key you have access to) and paste it in the SSH public key window of the UI.

            You can also use the **Browse** option in the wizard to select the id_ras.pub file.

    ![](images/ocp_public_key.png)
   
12. Click on **Generate Discovery ISO**

13. Copy the **Discovery ISO URL** and note it down somewhere. You will
    need this for your next section while creating infrastructure.

    ![](images/ocp_iso_url.png)

14. Click on **Close**

## Provision OCP Infrastructure

In this section we will create all infrastructure components for the OpenShift cluster. 

You are able to create these VMs and its resources using the Prism Element GUI. But in this section we will use **Terraform** code for repeatability and ease. Nutanix provides Terraform integration for managing the entire lifecycle of Nutanix resources (virtual machines, networks, etc). See [Terraform Nutanix Provider](https://github.com/nutanix/terraform-provider-nutanix) for details. 

We will create the following minimum required resources in preparation for our OpenShift cluster:
  
| OCP Role   |    Operating System    |    vCPU    |  RAM         | Storage   | IOPS |           
| -------------|  ---------------------- |  -------- | ----------- |  --------- |  -------- | 
| Bootstrap    |  RHCOS                 |  4       |  16 GB       | 100 GB    | 300 | 
| Master       |  RHCOS                 |  4        | 16 GB      |  100 GB   |  300 | 
| Worker       |  RHCOS               |  8  |  16 GB      |  100 GB |    300 | 

For latest resource requirements of an OpenShift cluster refer to [OpenShift portal](https://docs.openshift.com/container-platform/4.9/installing/installing_platform_agnostic/installing-platform-agnostic.html#installation-minimum-resource-requirements_installing-platform-agnostic).

1.  Login to your workstation

2.  Run the following command to install Terraform on your workstation

    === "Mac"

        ```bash
        brew tap hashicorp/tap
        brew install hashicorp/tap/terraform
        ```
    
    === "CentOS"
        
        ```bash
        yum update -y 
        yum install -y yum-utils
        yum-config-manager --add-repo https://rpm.releases.hashicorp.com/RHEL/hashicorp.repo
        yum -y install terraform
        yum -y install git
        ```

3.  Create a working directory
    
    ```bash
    mkdir ~/tf
    cd ~/tf
    ```

4. Export Nutanix infrastructure/cloud connection parameters to your environment variables.

    === "Template file"
    
        ```bash title="Setup to connect to Nutanix Prism Central (Infrastructure/Cloud Provider)"
        export PRISMCENTRAL_ADDRESS=""
        export PRISMCENTRAL_PORT=""
        export PRISMELEMENT_ADDRESS=""
        export PRISMELEMENT_PORT=""
        export PRISMELEMENT_CLUSTERNAME=""
        export PRISMELEMENT_NETWORKNAME=""
        export NUTANIX_USERNAME=""
        export NUTANIX_PASSWORD=""
        ```
        ```bash title="Setup for OCP environment variables"
        export INGRESS_IP=""
        export API_IP=""
        export VM_MASTER_PREFIX=""
        export VM_WORKER_PREFIX=""
        export VM_MASTER_COUNT=""
        export VM_WORKER_COUNT=""
        export RHCOS_IMAGE_URI=""
        ```
    
    === "Example file"
    
        ```bash title="Setup to connect to Nutanix Prism Central (Infrastructure/Cloud Provider)"
        export PRISMCENTRAL_ADDRESS="x.x.x.x"
        export PRISMCENTRAL_PORT="9440"
        export PRISMELEMENT_ADDRESS="x.x.x.x"
        export PRISMELEMENT_PORT="9440"
        export PRISMELEMENT_CLUSTERNAME="PECLUSTER"
        export PRISMELEMENT_NETWORKNAME="PECLUSTER_AHV_VLAN0"
        export NUTANIX_USERNAME="admin"
        export NUTANIX_PASSWORD="XXXXXXXX"
        ```
        ```bash title="Setup for OCP environment variables"
        export INGRESS_IP="x.x.x.x"
        export API_IP="x.x.x.x"
        export VM_MASTER_PREFIX="ocp-master-"
        export VM_WORKER_PREFIX="ocp-worker-"
        export VM_MASTER_COUNT="3"                                      #at least 3 are required 
        export VM_WORKER_COUNT="2"
        export RHCOS_IMAGE_URI="https://api.openshift.com/api/......"   #export the entire URL
        ```

 
4.  Download the following terraform files

    ```bash
    curl -OL https://raw.githubusercontent.com/nutanix-cloud-native/opendocs/main/docs/guides/openshift/install/assisted_installer/tf/main.tf
    curl -OL https://raw.githubusercontent.com/nutanix-cloud-native/opendocs/main/docs/guides/openshift/install/assisted_installer/tf/variables.tf
    curl -OL https://raw.githubusercontent.com/nutanix-cloud-native/opendocs/main/docs/guides/openshift/install/assisted_installer/tf/terraform.tfvars.sample
    ```

5.  Initialise Terraform
    
    ```bash
    tf init
    ```

6.  Get your variables file ready with your Nutanix AHV environment
    information

    ```bash
    cp terraform.tfvars.sample terraform.tfvars
    ```

7.  Modify your variables to suit your Nutanix environment

    ``` bash
    vi terraform.tfvars
    ```

    ```bash
    cluster_name        = ${PRISMELEMENT_CLUSTERNAME}
    subnet_name         = ${PRISMELEMENT_NETWORKNAME}
    user                = ${NUTANIX_USERNAME}
    password            = ${NUTANIX_PASSWORD}
    prismcentral        = ${PRISMCENTRAL_ADDRESS}
    vm_master_prefix    = ${VM_MASTER_PREFIX}
    vm_worker_prefix    = ${VM_WORKER_PREFIX}
    vm_master_count     = ${VM_MASTER_COUNT}
    vm_worker_count     = ${VM_COUNT_COUNT}
    image_uri           = ${RHCOS_IMAGE_URI}
    ```

8.  Validate your Terraform code

    ```bash
    tf validate
    ```

9.  Run Terraform plan to check what resources will be created 

    ```bash
    tf plan
    ```
    ``` { .bash .no-copy }
    # you will see the number of resources that will be created for confirmation
    Plan: 6 to add, 0 to change, 0 to destroy.
    ```


10.  Apply your Terraform code to create virtual machines and associated resources
  
    ```bash
    tf apply 

    # Terraform will show you all resources that it will to create
    # Type yes to confirm 
    ```

    ``` { .bash .no-copy }
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

10. Run the Terraform state list command to verify what resources have been created

    ``` bash
    tf state list
    ```

    ``` { .bash .no-copy }
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

11. Login to **Prism Central** > **Compute & Storage** > **VMs** and verify the VMs and if they are powered on

    ![](images/ocp_tf_vms.png)

## Install OCP Cluster in Red Hat Console

In this section we will use Red Hat Console's Assisted Installer wizard to install the OCP cluster with the VMs we have provisioned.

1.  Return to Red Hat Openshift Console and check if the VMs appear
    (this may take up to 5 minutes)

    ![](images/ocp_rh_console_vms.png)

2.  Click **Next** at the bottom of the page

3.  In the Networking section, assign IPs for your **API Virtual IP** and **Ingress Virtual IP** from your AHV network CIDR range (sample IPs provided in screenshot - use your own reserved IPs). See [pre-requisites](#pre-requisites-for-assisted-installation) section where you reserved IPs.
   
    ![](images/ocp_ing_api_ips.png)

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

    !!!tip
           There is a potential for automation for the eject process using [Nutanix REST APIs](https://www.nutanix.dev/api-reference/). 

### Access to your OpenShift Cluster

Create DNS entries in your environment to be able to access the OpenShift cluster.

- On your workstation - using ``/etc/hosts`` file

- On your network - creating entries in a DNS server (see [pre-requisites](#pre-requisites-for-assisted-installation))

The Installation wizard gives you DNS entries for your workstation as well as a centralised DNS server.

![](images/ocp_access.png)

Click on **Not able to access Web Console?** link in the status page to reveal IP addresses and DNS entry suggestions.

![](images/ocp_dns_hosts.png)


Once you have done creating DNS entries, you can access OpenShift cluster in two ways:

1. Using ``oc`` or ``kubectl`` commands 
   
    Download the kubeconfig file from the installation page of the Red Hat portal to your workstation
 
    ```bash title="Change kubeconfig file's access mode for security"
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

### Machine API Support - Optional

You are also able to configure machine API support for your dynamic workloads. You might want to do this to keep you worker nodes to a minimum in your private or public clouds to get effective value. The autoscaling functionality will allow for the nodes to be scaled up and down based on the requirements of the workloads. 

There are a few additional steps that you need to do. From a configuration perspective setup the following:


1. Patch your OCP cluster with the Nutanix infrastructure/cloud information
   
    ```bash
    oc patch infrastructure/cluster --type=merge --patch-file=/dev/stdin <<-EOF
    {
        "spec": {
        "platformSpec": {
            "nutanix": {
            "prismCentral": {
                "address": "${PRISMCENTRAL_ADDRESS}",
                "port": ${PRISMCENTRAL_PORT}
            },
            "prismElements": [
                {
                "endpoint": {
                    "address": "${PRISMELEMENT_ADDRESS}",
                    "port": ${PRISMELEMENT_PORT}
                },
                "name": "${PRISMELEMENT_CLUSTERNAME}"
                }
            ]
            },
            "type": "Nutanix"
        }
        }
    }
    EOF
    ```

3. Apply the Nutanix infrastructure/cloud credentials for authentication and authorisation
    
    ```bash
    cat << EOF | oc create -f -
    apiVersion: v1
    kind: Secret
    metadata:
      name: nutanix-credentials
      namespace: openshift-machine-api
    type: Opaque
    stringData:
     credentials: |
       [{"type":"basic_auth","data":{"prismCentral":{"username":"${NUTANIX_USERNAME}","password":"${NUTANIX_PASSWORD}"},"prismElements":null}}]
    EOF
    ```
4. Once you are done with Nutanix cloud connection information you are able to continue with creating MachineSet to support your workloads. For information on creating MachineSet refer to the RedHat document [here](https://docs.openshift.com/container-platform/4.12/machine_management/creating_machinesets/creating-machineset-nutanix.html). 


## Takeaways

-   You can easily deploy multinode/single node OCP cluster using the Assisted Installer in Red Hat console
-   You can provision resources (VM, Storage, etc) on Nutanix using Terraform IaaC (GitOps)
    
    !!!info "Good to know"

          The Installer Provisioned Installer (IPI) also uses Terraform to deploy infrastructure assets (VM) on Nutanix and VMware

-   Assisted Installer provisioned OCP clusters can be used as a learning ground and for testing purposes

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

An administrator will need to provision all the infrastructure related components and Assisted Installation process can used provision a OpenShift cluster. 

This offers quite a few options for customising the following:

- Virtual Machines 
  - CPU, memory, networking and storage
- General networking services - DNS and DHCP services
- Security services - firewall
- Placement of resources in different locations (where supported by OpenShift)
- IDP services - Active Directory, LDAP, etc.

Once the infrastructure components are provisioned and ready for use, Assisted Installation process can take over and deploy a OpenShift cluster.
  
## Pre-requisites for Assisted Installation

!!!info "Assister Installer Pre-requisites Reference"
       
       The OCP clusters deployed using Assisted Installers can be used for production, testing and development purposes conforming to these [pre-requisites](https://cloud.redhat.com/blog/using-the-openshift-assisted-installer-service-to-deploy-an-openshift-cluster-on-metal-and-vsphere#:~:text=Pre%2Drequisites,required%20for%20accessing%20the%20cluster).    

- Access to [Red Hat Console](https://console.redhat.com/) (portal) to use Assisted Installer and install a OpenShift cluster, add extra OpenShift nodes (at a later time), etc.
- OpenShift CLI installation [here](https://docs.openshift.com/container-platform/4.8/cli_reference/openshift_cli/getting-started-cli.html).
- OCP Master and Worker virtual machines on Nutanix HCI platform created by the administrator
- Compute, networking and storage associated with the OCP Master and Worker VMs provisioned by the administrator
-  AHV Network - configured with DNS and DHCP pool in the environment
-   A SSH key pair for the OCP Control plane and Worker virtual machines

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

-   Find and reserve two static IPs for OpenShift cluster's ``API`` and network ``Ingress`` endpoints in the same CIDR as the yet to be installed OCP Control plane and worker VMs. 
    
    !!!warning
              Make sure to exclude the assigned IPs for ``API`` and network ``Ingress`` endpoints from any DHCP server's scope. 
   
              Do not proceed with installation unless you have made sure that none of the DHCP servers in your environment is distributing these IPs. 
   
- Add reserved static IPs to the environment's DNS server for the ``API`` and ``Ingress`` endpoints

    ???info "Steps to add DNS entries for API and Ingress Endpoints"

        We will add API and APPS Ingress DNS records for lookup by OCP IPI installer.

        Export two reserved IPs to your environment variables to use with ``API`` and ``Ingress`` 
        endpoints.

        ```bash
        export API_IP="x.x.x.x"
        export INGRESS_IP="x.x.x.x"
        ```
        
        The OCP cluster's name becomes a subdomain in your DNS zone ``example.com``. All OCP cluster related lookups are located within subdomain.
        
        - **Main domain** -  ``domainname`` (e.g: ``example.com``)
        - **Sub domain** - ``ocpclustername`` (e.g: ``ocp-cluster``)
        - **FQDN** - ``ocpclustername.domainname`` (e.g: ``ocp-cluster.example.com`` )
        
        In your environment's DNS server, configure the following DNS entries using the two IPs you found in the previous section: 
        
        - One ``A`` record DNS entry for OCP cluster's API
        
            ``` { .text .no-copy }
            ${API_IP} == api.ocp-cluster.example.com
            ```
        
        - One wildcard ``A`` record DNS entry for the OCP cluster's Ingress 
        
            ``` { .text .no-copy }
            ${INGRESS_IP} == *.ocp-cluster.example.com
            ``` 

## Overview of Assisted Installation Process

Assisted Installer does the following:

-   Provides Red Hat Core Operating System (RHCOS) and OCP installation binaries in a CD-ROM ISO file
-   The OCP VMs/nodes (Control plane and Worker) are booted with this CD-ROM ISO file
-   VMs show in Assisted Installer page (Red Hat Console)
-   The administrator chooses the role of the VMs (Control plane and worker nodes)
-   Assisted installer will choose one of the Control plane VM to serve the Bootstrap role during cluster installation
-   Red Hat Console will manage and monitor the installation process from start to finish
-   Upon successful installation of a OCP cluster the following will be provided:
    -   KUBECONFIG file for `oc` command line access
    -   Configurable DNS entries for OCP Cluster access
### High Level Installation Steps 

At a high level, we will do the following to get a OCP cluster deployed using Assisted Installer:

1.  Provision OCP Cluster in Red Hat Console
2.  Generate CD-ROM ISO URL
3.  Provision OCP Infrastructure - Create Control plane and worker VMs in your Nutanix cluster
4.  Nutanix AHV cluster using Terraform infrastructure as code
5.  Install OCP Cluster from Red Hat Console (portal)

## Provision OCP Cluster in Red Hat Console

1.  Go to [Red Hat Console](https://console.redhat.com/openshift/assisted-installer/clusters)
   
2.  Login using your Red Hat Console portal's credentials

3.  Click on **OpenShift**

4.  Click on **Datacenter** tab 
   
5.  Under Assisted Installer, click on **Create Cluster**

6.  Fill in the following details:

    -   **Cluster name**                 - ``ocp clustername`` (e.g: ocp-cluster)
    -   **Base domain**                  - ``domainname`` (e.g: example.com)
    -   **OpenShift version**            - choose the version from drop-down (e.g OpenShift 4.12.9)
    -   **CPU architecture**             - x86_64
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

Creating infrastructure elements (VMs, associated disks, etc) for the purpose of OCP Kubernetes cluster installation can be accomplished using the Prism Element UI or using APIs offered by Nutanix. Refer to our OCP Assisted Installer [Solutions](../../../../openshift/install/assisted_installer/index.md#installation-steps) section for more information on these methods.

In this section we will use **Terraform** Infrastructure as code (IaC) tool for repeatability and ease. Nutanix provides Terraform integration for managing the entire lifecycle of Nutanix infrastructure resources. See [Terraform Nutanix Provider](https://github.com/nutanix/terraform-provider-nutanix) for details. 

We will create the following minimum required resources in preparation for our OpenShift cluster:
  
| OCP Role   |    Operating System    |    vCPU    |  RAM         | Storage   | IOPS |           
| -------------|  ---------------------- |  -------- | ----------- |  --------- |  -------- | 
| Bootstrap    |  RHCOS                 |  4       |  16 GB       | 100 GB    | 300 | 
| Control plane       |  RHCOS                 |  4        | 16 GB      |  100 GB   |  300 | 
| Worker       |  RHCOS               |  8  |  16 GB      |  100 GB |    300 | 

For latest resource requirements of an OpenShift cluster refer to [OpenShift portal](https://docs.openshift.com/container-platform/4.9/installing/installing_platform_agnostic/installing-platform-agnostic.html#installation-minimum-resource-requirements_installing-platform-agnostic).

1.  Login to your workstation

2. Export Nutanix infrastructure/cloud connection parameters to your environment variables.

    === "Template commands"
    
        ```bash title="Setup to connect to Nutanix Prism Central (Infrastructure/Cloud Provider)"
        export TF_VAR_PRISMCENTRAL_ADDRESS=""
        export TF_VAR_PRISMELEMENT_CLUSTERNAME=""
        export TF_VAR_PRISMELEMENT_NETWORKNAME=""
        export TF_VAR_NUTANIX_USERNAME=""
        export TF_VAR_NUTANIX_PASSWORD=""
        ```
        ```bash title="Setup for OCP environment variables"
        export TF_VAR_VM_MASTER_PREFIX=""
        export TF_VAR_VM_WORKER_PREFIX=""
        export TF_VAR_VM_MASTER_COUNT=""             # 3 Control plane nodes are required 
        export TF_VAR_VM_WORKER_COUNT=""
        export TF_VAR_RHCOS_IMAGE_URI=""             # Export the entire URL
        ```
    
    === "Example commands"
    
        ```bash title="Setup to connect to Nutanix Prism Central (Infrastructure/Cloud Provider)"
        export TF_VAR_PRISMCENTRAL_ADDRESS="x.x.x.x"
        export TF_VAR_PRISMELEMENT_CLUSTERNAME="PECLUSTER"
        export TF_VAR_PRISMELEMENT_NETWORKNAME="PECLUSTER_AHV_VLAN0"
        export TF_VAR_NUTANIX_USERNAME="admin"
        export TF_VAR_NUTANIX_PASSWORD="XXXXXXX"
        ```
        ```bash title="Setup for OCP environment variables"
        export TF_VAR_VM_MASTER_PREFIX="ocp-master-"
        export TF_VAR_VM_WORKER_PREFIX="ocp-worker-"
        export TF_VAR_VM_MASTER_COUNT="3"            
        export TF_VAR_VM_WORKER_COUNT="2"
        export TF_VAR_RHCOS_IMAGE_URI="https://api.openshift.com/api/......"
        ```

3.  Run the following command to install Terraform on your workstation

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
    ???info "Terraform on another OS?"

           Check Terraform documenation [here](https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli) to install. 

4.  Create a working directory
    
    ```bash
    mkdir ~/tf
    cd ~/tf
    ```
 
5.  Download the following terraform files

    ```bash
    curl -OL https://raw.githubusercontent.com/nutanix-cloud-native/opendocs/main/docs/guides/openshift/install/assisted_installer/tf/main.tf
    curl -OL https://raw.githubusercontent.com/nutanix-cloud-native/opendocs/main/docs/guides/openshift/install/assisted_installer/tf/variables.tf
    ```

6.  Initialise Terraform
    
    ```bash
    terraform init
    ```

7.  Validate your Terraform code

    ```bash
    terraform validate
    ```

8.  Run Terraform plan to check what resources will be created 

    ```bash
    terraform plan
    ```
    ``` { .bash .no-copy }
    # you will see the number of resources that will be created for confirmation
    Plan: 6 to add, 0 to change, 0 to destroy.
    ```


10.  Apply your Terraform code to create virtual machines and associated resources
  
    ```bash
    terraform apply 

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
    terraform state list
    ```

    ``` { .bash .no-copy }
    # Sample output for the above command

    data.nutanix_cluster.cluster            # < This is your existing Prism cluster
    data.nutanix_subnet.subnet              # < This is your existing Prism network name
    nutanix_image.RHCOS                     # < This is RHCOS ISO image
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

1.  Return to Red Hat Openshift Console and check if the VMs appear (this may take up to 5 minutes)
   
2.  Assign roles to your nodes from the drop-down (at least three Control plane nodes)

    ![](images/ocp_rh_console_vms.png)

3.  Click **Next** at the bottom of the page

4.  In the Networking section 
   
    - **Machine network** - choose the CIDR of the ``${TF_VAR_PRISMELEMENT_NETWORKNAME}`` network
    - **API Virtual IP** -  input the value of ``${API_IP}`` variable
    - **Ingress Virual IP** - input the value of ``${INGRESS_IP} ``variable

5.  Click **Next** at the bottom of the page

6.  Review your setup information and click on **Install Cluster**

7.  You will be taken to monitoring your installation progress

    ![](images/ocp_install_start.png)

    Now the cluster deploy will proceed

8.  Watch for any messages about user interactions in the progress page

    ![](images/ocp_user_inter.png)

    This message is wanting the user to unmount the installation Discovery ISO so they VM can boot into the OS drive

9.  Go to **Prism Central** > **Compute & Storage** > **VM**

10. Select the VM in question and click on **Update**
    
11. Click **Next**

12. Under Disks > Click on Eject

    ![](images/pe_vm_cd_eject.png)

13. Click on **Next** twice
    
14. Click on **Save**

15. Guest Reboot the VM once done which will then boot the VM into the OS disk 

16. Repeat ejecting CD-ROM for all VMs and rebooting it as the Wizard prompts for user action (do not do this before the prompting)

17. Once all the user actions are sustained for Control plane and Worker VMs, OCP cluster will be installed

    !!!tip
           There is a potential for automation for the eject process using [Nutanix REST APIs](https://www.nutanix.dev/api-reference/). 

### Access to your OpenShift Cluster

Once you have done creating DNS entries as specified in [pre-requisites](#pre-requisites-for-assisted-installation) section, you can access OpenShift cluster in two ways:

1. Using OpenShift CLI ``oc`` command
   
    Download the kubeconfig file from the installation page of the Red Hat portal to your workstation
 
    ```bash title="Change kubeconfig file's access mode for security"
    chmod 400 kubeconfig
    ```
    ```bash title="Export kubeconfig to PATH"
    export KUBECONFIG=/path/to/kubeconfig
    ```
    ```bash title="Execute oc commands to confirm connectivity to cluster"
    oc get nodes
    ```

2. Using the OpenShift Clusters Web UI: 
    
    === "Template URL"

        ```URL
        http:\\console-openshift-console.apps.subdomain.domain.com
        ```

    === "Example URL"

        ```URL title="Using ocp-cluster and example.com as FQDN"
        http:\\console-openshift-console.apps.ocp-cluster.example.com
        ```

### Machine API Support - optional

Machine API support allows for OCP nodes to scale out and scale in to accommodate dynamic requirements of workloads.

The following few additional steps are required to configure Machine API support:

1. Export environment variables for configuration
   
    ```bash
    export PRISMCENTRAL_PORT=9440
    export PRISMELEMENT_PORT=9440
    ```

2. Patch the OCP cluster with the Nutanix infrastructure/cloud information
   
    
    ```bash
    oc patch infrastructure/cluster --type=merge --patch-file=/dev/stdin <<-EOF
    {
        "spec": {
        "platformSpec": {
            "nutanix": {
            "prismCentral": {
                "address": "${TF_VAR_PRISMCENTRAL_ADDRESS}",
                "port": ${PRISMCENTRAL_PORT}
            },
            "prismElements": [
                {
                "endpoint": {
                    "address": "${TF_VAR_PRISMELEMENT_ADDRESS}",
                    "port": ${PRISMELEMENT_PORT}
                },
                "name": "${TF_VAR_PRISMELEMENT_CLUSTERNAME}"
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
       [{"type":"basic_auth","data":{"prismCentral":{"username":"${TF_VAR_NUTANIX_USERNAME}","password":"${TF_VAR_NUTANIX_PASSWORD}"},"prismElements":null}}]
    EOF
    ```
4. The next step is to create ``MachineSet`` to support your workloads. For information on creating MachineSet refer to the RedHat document [here](https://docs.openshift.com/container-platform/4.12/machine_management/creating_machinesets/creating-machineset-nutanix.html). 


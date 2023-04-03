# Red Hat OpenShift Container Platform Assisted Installation on Nutanix AOS (AHV)

!!!note "Nutanix AOS, Prism Central and Openshift Compatibility"
         
         Red Hat OpenShift Container Platform Assisted Installer has been tested for specific compatibility on following AOS and Prism Central versions:

         | Openshift | AOS              | Prism Central |
         |:-----------:|:-------------------:|:---------------:|
         | 4.12      | 5.20.4+ or 6.5.1+ | 2022.4+       |
         | 4.11      | 5.20.4+ or 6.1.1+ | 2022.4+       |

More information on Red Hat OpenShift Container Platform Assisted Installer can be found in [Installing an on-premise cluster using the Assisted Installer](https://docs.openshift.com/container-platform/latest/installing/installing_on_prem_assisted/installing-on-prem-assisted.html){target=_blank}. 

## Installation Steps

1. Review the prerequisites in [Preparing to install with the Assisted Installer](https://access.redhat.com/documentation/en-us/assisted_installer_for_openshift_container_platform/2022/html-single/assisted_installer_for_openshift_container_platform/index#preparing-to-install-with-ai){target=_blank}.
2. Access [Install OpenShift with the Assisted Installer](https://console.redhat.com/openshift/assisted-installer/clusters/~new){target=_blank} on the Red Hat OpenShift Cluster Manager site. If you have a Red Hat account, log in with your credentials. If you do not, create an account.
3. Follow the UI or API-based installation steps:
    - UI:
        - [Installing with the Assisted Installer UI](https://access.redhat.com/documentation/en-us/assisted_installer_for_openshift_container_platform/2022/html-single/assisted_installer_for_openshift_container_platform/index#installing-with-ui){target=_blank}
        - [Adding hosts on Nutanix with the UI](https://access.redhat.com/documentation/en-us/assisted_installer_for_openshift_container_platform/2022/html-single/assisted_installer_for_openshift_container_platform/index#adding-hosts-on-nutanix-with-the-ui_assembly_installing-on-nutanix){target=_blank}
    - API:
        - [Installing with the Assisted Installer API](https://access.redhat.com/documentation/en-us/assisted_installer_for_openshift_container_platform/2022/html-single/assisted_installer_for_openshift_container_platform/index#installing-with-api){target=_blank}
        - [Adding hosts on Nutanix with the API](https://access.redhat.com/documentation/en-us/assisted_installer_for_openshift_container_platform/2022/html-single/assisted_installer_for_openshift_container_platform/index#adding-hosts-on-nutanix-with-the-api_assembly_installing-on-nutanix){target=_blank}

## Installation Guide

A step-by-step Assisted Installer [Installation Guide](../../../guides/openshift/install/assisted/assisted.md) is available for you on this site in the Guides section. The guide uses the following:

- [Nutanix Terraform Provider](https://registry.terraform.io/providers/nutanix/nutanix/latest/docs) to build the virtual machines and other infrastructure resources
- [Install OpenShift with the Assisted Installer](https://console.redhat.com/openshift/assisted-installer/clusters/~new){target=_blank} to detect the Nutanix infrastructure components and install OpenShift Kubernetes cluster
## Post Installation Steps

1. Perform the [Nutanix post-installation configuration](https://access.redhat.com/documentation/en-us/assisted_installer_for_openshift_container_platform/2022/html-single/assisted_installer_for_openshift_container_platform/index#nutanix-post-installation-configuration_assembly_installing-on-nutanix){target=_blank}.
2. Follow the [post install](/openshift/post-install){target=_blank} instructions to complete cluster configuration.

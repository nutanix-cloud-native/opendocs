# Red Hat OpenShift Container Platform Installer Provisioned Installation on Nutanix AOS (AHV)

**Note:** Red Hat OpenShift Container Platform IPI version 4.11 has been tested for specific compatibility on Nutanix AOS 5.20.4 and 6.1.1 with Prism Central 2022.4.

## Installation Prerequisites

### Certificate Requirements

 If your Prism Central instance is using the default self-signed SSL certificate, the certificate must be replaced with one signed by a trusted CA. The installation program requires a valid CA-signed certificate to access to the Prism Central API. For more information about replacing the self-signed certificate, see the [Nutanix AOS Security Guide](https://portal.nutanix.com/page/documents/details?targetId=Nutanix-Security-Guide-v6_1:mul-security-ssl-certificate-pc-t.html){target=_blank}.

 Prism Central certificates created using [Let's Encrypt](https://letsencrypt.org/){target=_blank} may need to be added to your system trust before you install an OpenShift Container Platform cluster. If you do not already have access to the Prism Central CA certificate bundle, it can often be exported from your browser after visiting the Prism Central URL.

### Firewall Requirements

 During an IPI installation, Prism Central's Image Service directly downloads the Red Hat Enterprise Linux CoreOS (RHCOS) image that is required to install the cluster. The Image Service must have access to download the RHCOS image from `rhcosredirector.apps.art.xq1c.p1.openshiftapps.com`.

1. Review the [OpenShift documentation](https://docs.openshift.com/container-platform/latest/installing/installing_nutanix/preparing-to-install-on-nutanix.html){target=_blank} for further steps on preparing your environment for installation.

## Installation

1. Review the [OpenShift documentation](https://docs.openshift.com/container-platform/latest/installing/installing_nutanix/installing-nutanix-installer-provisioned.html){target=_blank} to complete the installation.

## Post Install

1. Follow the [post install](/openshift/post-install) instructions to complete cluster configuration.


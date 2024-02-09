# Red Hat OpenShift Container Platform Installer Provisioned Installation on Nutanix AOS (AHV)

!!! note
    Visit the [Red Hat OpenShift Container Platform documentation](https://docs.openshift.com/container-platform/latest/installing/installing_nutanix/preparing-to-install-on-nutanix.html){target=_blank} to learn more about the tested AOS and Prism Central versions.

## Installation Prerequisites

### Certificate Requirements

 If your Prism Central instance is using the default self-signed SSL certificate, the certificate must be replaced with one signed by a publicly trusted CA. The installation program requires a valid public CA-signed certificate to access to the Prism Central API. For more information about replacing the self-signed certificate, see the [Nutanix AOS Security Guide](https://portal.nutanix.com/page/documents/details?targetId=Nutanix-Security-Guide-v6_1:mul-security-ssl-certificate-pc-t.html){target=_blank}.

 Prism Central certificates created using [Let's Encrypt](https://letsencrypt.org/){target=_blank} may need to be added to your system trust before you install an OpenShift Container Platform cluster. If you do not already have access to the Prism Central CA certificate bundle, it can often be exported from your browser after visiting the Prism Central URL.

 If your Prism Central certificate is not chained to a trusted public CA, the CA certificate must be added to the `additionalTrustBundle` section of `install-config.yaml` after it is created. Follow the process documented in [OpenShift documentation](https://docs.openshift.com/container-platform/latest/installing/installing_nutanix/installing-nutanix-installer-provisioned.html#installation-configure-proxy_installing-nutanix-installer-provisioned){target=_blank} to add the certificate. It is not required to configure the documented `proxy` sections, only to add the certificate. 
 
 Additionally, after installation manfiests are created, the proxy spec in the cluster proxy manifest must be updated to specify that the `user-ca-bundle` CA bundle is trusted. For example, in `manifests/cluster-proxy-01-config.yaml`:

        apiVersion: config.openshift.io/v1
        kind: Proxy
        metadata:
          creationTimestamp: null
          name: cluster
        spec:
          trustedCA:
            name: "user-ca-bundle"

!!! note
    Starting from Openshift 4.12, `additionalTrustBundlePolicy` can be specified in `install-config.yaml`. When setting the `additionalTrustBundlePolicy` to `Always`, the `user-ca-bundle` will automatically be configured in the `manifests/cluster-proxy-01-config.yaml` file. 


### Firewall Requirements

 During an IPI installation, Prism Central's Image Service directly downloads the Red Hat Enterprise Linux CoreOS (RHCOS) image that is required to install the cluster. The Image Service must have access to download the RHCOS image from `rhcos.mirror.openshift.com`.

1. Review the [OpenShift documentation](https://docs.openshift.com/container-platform/latest/installing/installing_nutanix/preparing-to-install-on-nutanix.html){target=_blank} for further steps on preparing your environment for installation.

## Installation

1. Review the [OpenShift documentation](https://docs.openshift.com/container-platform/latest/installing/installing_nutanix/installing-nutanix-installer-provisioned.html){target=_blank} to complete the installation.

## Post Install

1. Follow the [post install](/openshift/post-install) instructions to complete cluster configuration.


# Red Hat OpenShift Container Platform Installer Provisioned Installation on Nutanix AOS (AHV)

**Note:** Red Hat OpenShift Container Platform IPI version 4.11 has been tested for specific compatibility on Nutanix AOS 5.20.4 and 6.1.1 with Prism Central 2022.4.

## Installation Prerequisites

### Certificate Requirements

 If your Prism Central instance is using the default self-signed SSL certificate, the certificate must be replaced with one signed by a publicly trusted CA. The installation program requires a valid public CA-signed certificate to access to the Prism Central API. For more information about replacing the self-signed certificate, see the [Nutanix AOS Security Guide](https://portal.nutanix.com/page/documents/details?targetId=Nutanix-Security-Guide-v6_1:mul-security-ssl-certificate-pc-t.html){target=_blank}.

 Prism Central certificates created using [Let's Encrypt](https://letsencrypt.org/){target=_blank} may need to be added to your system trust before you install an OpenShift Container Platform cluster. If you do not already have access to the Prism Central CA certificate bundle, it can often be exported from your browser after visiting the Prism Central URL.

 If your Prism Central certificate is not chained to a trusted public CA, the CA certificate must be added to the `additionalTrustBundle` section of `install-config.yaml` after it is created. Follow the process documented in [OpenShift documentation](https://docs.openshift.com/container-platform/4.11/installing/installing_nutanix/installing-nutanix-installer-provisioned.html#installation-configure-proxy_installing-nutanix-installer-provisioned){target=_blank} to add the certificate. It is not required to configure the documented `proxy` sections, only to add the certificate. Additionally, after installation manfiests are created, the proxy spec in the cluster proxy manifest must be updated to specify that the `user-ca-bundle` CA bundle is trusted. For example, in `manifests/cluster-proxy-01-config.yaml`:

        apiVersion: config.openshift.io/v1
        kind: Proxy
        metadata:
          creationTimestamp: null
          name: cluster
        spec:
          trustedCA:
            name: "user-ca-bundle"
    
### Firewall Requirements

 During an IPI installation, Prism Central's Image Service directly downloads the Red Hat Enterprise Linux CoreOS (RHCOS) image that is required to install the cluster. The Image Service must have access to download the RHCOS image from `rhcosredirector.apps.art.xq1c.p1.openshiftapps.com`.

1. Review the [OpenShift documentation](https://docs.openshift.com/container-platform/latest/installing/installing_nutanix/preparing-to-install-on-nutanix.html){target=_blank} for further steps on preparing your environment for installation.

## Installation

1. Review the [OpenShift documentation](https://docs.openshift.com/container-platform/latest/installing/installing_nutanix/installing-nutanix-installer-provisioned.html){target=_blank} to complete the installation.

## Post Install

1. Follow the [post install](/openshift/post-install) instructions to complete cluster configuration.


# Certificate Trust

CAPX invokes Prism Central APIs using the HTTPS protocol. CAPX has different methods to handle the trust of the Prism Central certificates:

- Enable certificate verification (default)
- Configure an additional trust bundle
- Disable certificate verification

See the respective sections below for more information.

!!! note
    For more information about replacing Prism Central certificates, see the [Nutanix AOS Security Guide](https://portal.nutanix.com/page/documents/details?targetId=Nutanix-Security-Guide-v6_5:mul-security-ssl-certificate-pc-t.html){target=_blank}.

## Enable certificate verification (default)
By default CAPX will perform certificate verification when invoking Prism Central API calls. This requires Prism Central to be configured with a publicly trusted certificate authority. 
No additional configuration is required in CAPX.

## Configure an additional trust bundle
CAPX allows users to configure an additional trust bundle. This will allow CAPX to verify certificates that are not issued by a publicy trusted certificate authority. 

To configure an additional trust bundle, the `NUTANIX_ADDITIONAL_TRUST_BUNDLE` environment variable needs to be set. The value of the `NUTANIX_ADDITIONAL_TRUST_BUNDLE` environment variable contains the trust bundle (PEM format) in base64 encoded format. See the [Configuring the trust bundle environment variable](#configuring-the-trust-bundle-environment-variable) section for more information.

It is also possible to configure the additional trust bundle manually by creating a custom `cluster-template`. See the [Configuring the additional trust bundle manually](#configuring-the-additional-trust-bundle-manually)  section for more information

The `NUTANIX_ADDITIONAL_TRUST_BUNDLE` environment variable can be set when initializing the CAPX provider or when creating a workload cluster. If the `NUTANIX_ADDITIONAL_TRUST_BUNDLE` is configured when the CAPX provider is initialized, the additional trust bundle will be used for every CAPX workload cluster. If it is only configured when creating a workload cluster, it will only be applicable for that specific workload cluster.


### Configuring the trust bundle environment variable

Create a PEM encoded file containing the root certificate and all intermediate certificates. Example:
```
$ cat cert.crt
-----BEGIN CERTIFICATE-----
<certificate string>
-----END CERTIFICATE-----
-----BEGIN CERTIFICATE-----
<certificate string>
-----END CERTIFICATE-----
```

Use a `base64` tool to encode these contents in base64. The command below will provide a `base64` string.
```
$ cat cert.crt | base64
<base64 string>
```
!!! note
    Make sure the `base64` string does not contain any newlines (`\n`). If the output string contains newlines, remove them manually or check the manual of the `base64` tool on how to generate a `base64` string without newlines. 

Use the `base64` string as value for the `NUTANIX_ADDITIONAL_TRUST_BUNDLE` environment variable.
```
$ export NUTANIX_ADDITIONAL_TRUST_BUNDLE="<base64 string>"
```

### Configuring the additional trust bundle manually

To configure the additional trust bundle manually without using the `NUTANIX_ADDITIONAL_TRUST_BUNDLE` environment variable present in the default `cluster-template` files, it is required to:

- Create a `ConfigMap` containing the additional trust bundle.
- Configure the `prismCentral.additionalTrustBundle` object in the `NutanixCluster` spec.

#### Creating the additional trust bundle ConfigMap

CAPX supports two different formats for the ConfigMap containing the additional trust bundle. The first one is to add the additional trust bundle as a multi-line string in the `ConfigMap`, the second option is to add the trust bundle in `base64` encoded format. See the examples below.

Multi-line string example:
```YAML
---
apiVersion: v1
kind: ConfigMap
metadata:
  name: user-ca-bundle
  namespace: ${NAMESPACE}
data:
   ca.crt: |
    -----BEGIN CERTIFICATE-----
    <certificate string>
    -----END CERTIFICATE-----
    -----BEGIN CERTIFICATE-----
    <certificate string>
    -----END CERTIFICATE-----
```

`base64` example:

```YAML
apiVersion: v1
kind: ConfigMap
metadata:
  name: user-ca-bundle
  namespace: ${NAMESPACE}
binaryData:
  ca.crt: <base64 string>
```

!!! note
    The `base64` string needs to be added as `binaryData`.


#### Configuring the NutanixCluster spec

When the additional trust bundle `ConfigMap` is created, it needs to be referenced in the `NutanixCluster` spec. Add the `prismCentral.additionalTrustBundle` object in the `NutanixCluster` spec as shown below. Make sure the correct additional trust bundle `ConfigMap` is referenced.

```YAML
apiVersion: infrastructure.cluster.x-k8s.io/v1beta1
kind: NutanixCluster
metadata:
  name: ${CLUSTER_NAME}
  namespace: ${NAMESPACE}
spec:
  ...
  prismCentral:
    ...
    additionalTrustBundle:
      kind: ConfigMap
      name: user-ca-bundle
    insecure: false
```

!!! note
    the default value of `prismCentral.insecure` attribute is `false`. It can be omitted when an additional trust bundle is configured. 
    
    If `prismCentral.insecure` attribute is set to `true`, all certificate verification will be disabled. 


## Disable certificate verification

!!! note
    Disabling certificate verification is not recommended for production purposes and should only be used for testing.


Certificate verification can be disabled by setting the `prismCentral.insecure` attribute to `true` in the `NutanixCluster` spec. Certificate verification will be disabled even if an additional trust bundle is configured. 

Disabled certificate verification example:

```YAML
apiVersion: infrastructure.cluster.x-k8s.io/v1beta1
kind: NutanixCluster
metadata:
  name: ${CLUSTER_NAME}
  namespace: ${NAMESPACE}
spec:
  controlPlaneEndpoint:
    host: ${CONTROL_PLANE_ENDPOINT_IP}
    port: ${CONTROL_PLANE_ENDPOINT_PORT=6443}
  prismCentral:
    ...
    insecure: true
    ...
```
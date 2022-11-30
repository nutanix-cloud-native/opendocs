# NutanixCluster

The `NutanixCluster` resource defines the configuration of a CAPX Kubernetes cluster. 

Example of a `NutanixCluster` resource:

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
    address: ${NUTANIX_ENDPOINT}
    additionalTrustBundle:
      kind: ConfigMap
      name: user-ca-bundle
    credentialRef:
      kind: Secret
      name: ${CLUSTER_NAME}
    insecure: ${NUTANIX_INSECURE=false}
    port: ${NUTANIX_PORT=9440}
```

## NutanixCluster spec
The table below provides an overview of the supported parameters of the `spec` attribute of a `NutanixCluster` resource.

### Configuration parameters

| Key                                        |Type  |Description                                                                       |
|--------------------------------------------|------|----------------------------------------------------------------------------------|
|controlPlaneEndpoint                        |object|Defines the host IP and port of the CAPX Kubernetes cluster.                      |
|controlPlaneEndpoint.host                   |string|Host IP to be assigned to the CAPX Kubernetes cluster.                            |
|controlPlaneEndpoint.port                   |int   |Port of the CAPX Kubernetes cluster. Default: `6443`                              |
|prismCentral                                |object|(Optional) Prism Central endpoint definition.                                     |
|prismCentral.address                        |string|IP/FQDN of Prism Central.                                                         |
|prismCentral.port                           |int   |Port of Prism Central. Default: `9440`                                            |
|prismCentral.insecure                       |bool  |Disable Prism Central certificate checking. Default: `false`                      |
|prismCentral.credentialRef                  |object|Reference to credentials used for Prism Central connection.                       |
|prismCentral.credentialRef.kind             |string|Kind of the credentialRef. Allowed value: `Secret`                                |
|prismCentral.credentialRef.name             |string|Name of the secret containing the Prism Central credentials.                      |
|prismCentral.credentialRef.namespace        |string|(Optional) Namespace of the secret containing the Prism Central credentials.      |
|prismCentral.additionalTrustBundle          |object|Reference to the certificate trust bundle used for Prism Central connection.      |
|prismCentral.additionalTrustBundle.kind     |string|Kind of the additionalTrustBundle. Allowed value: `ConfigMap`                     |
|prismCentral.additionalTrustBundle.name     |string|Name of the `ConfigMap` containing the Prism Central trust bundle.                |
|prismCentral.additionalTrustBundle.namespace|string|(Optional) Namespace of the `ConfigMap` containing the Prism Central trust bundle.|

!!! note
    To prevent duplicate IP assignments, it is required to assign an IP-address to the `controlPlaneEndpoint.host` variable that is not part of the Nutanix IPAM or DHCP range assigned to the subnet of the CAPX cluster.
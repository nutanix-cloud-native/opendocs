# Nutanix CCM Configuration

Nutanix CCM can be configured via a `JSON` formated file stored in a configmap called `nutanix-config`. This configmap is located in the same namespace as the Nutanix CCM deployment. See the `manifests/cloud-provider-nutanix-deployment.yaml` file for details on the Nutanix CCM deployment. 

Example `nutanix-config` configmap:
```YAML
---
kind: ConfigMap
apiVersion: v1
metadata:
  name: nutanix-config
  namespace: kube-system
data:
  nutanix_config.json: |-
    {
      "prismCentral": {
        "address": "${NUTANIX_ENDPOINT}",
        "port": ${NUTANIX_PORT},
        "insecure": ${NUTANIX_INSECURE},
        "credentialRef": {
          "kind": "secret",
          "name": "nutanix-creds"
        },
        "additionalTrustBundle": {
          "kind": "ConfigMap",
          "name": "user-ca-bundle"
        }
      },
      "enableCustomLabeling": false,
      "ignoredNodeIPs": [],
      "topologyDiscovery": {
        "type": "Categories",
        "topologyCategories": {
          "regionCategory": "${NUTANIX_REGION_CATEGORY}",
          "zoneCategory": "${NUTANIX_ZONE_CATEGORY}"
        }
      }
    }

```

The table below provides an overview of the supported configuration parameters.

### Configuration parameters

| Key                                               |Type  |Description                                                                                                                                           |
|---------------------------------------------------|------|------------------------------------------------------------------------------------------------------------------------------------------------------|
|topologyDiscovery                                  |object|(Optional) Configures the topology discovery mode.<br>`Prism` topology discovery is used by default if `topologyDiscovery` attribute is not passed.   |
|topologyDiscovery.type                             |string|Topology Discovery mode. Can be `Prism` or `Categories`. See [Topology Discovery](./topology_discovery.md) for more information.                      |
|topologyDiscovery.topologyCategories               |object|Required if topology discovery mode is `Categories`.<br>                                                                                              |
|topologyDiscovery.topologyCategories.regionCategory|string|Category key defining the region of the Kubernetes node.                                                                                              |
|topologyDiscovery.topologyCategories.zoneCategory  |string|Category key defining the zone of the Kubernetes node.                                                                                                |
|enableCustomLabeling                               |bool  |Boolean value to enable custom labeling. See [Custom Labeling](./custom_labeling.md) for more information.<br>Default: `false`                        |
|ignoredNodeIPs                                     |array |List of node IPs to ignore. Optional.                                                                                                                 |
|prismCentral                                       |object|Prism Central endpoint configuration.                                                                                                                 |
|prismCentral.address                               |string|FQDN/IP of the Prism Central endpoint.                                                                                                                |
|prismCentral.port                                  |int   |Port to connect to Prism Central.<br>Default: `9440`                                                                                                  |
|prismCentral.insecure                              |bool  |Disable Prism Central certificate checking.<br>Default: `false`                                                                                       |
|prismCentral.credentialRef                         |object|Prism Central credential configuration. See [Credentials](./ccm_credentials.md) for more information.                                                 |
|prismCentral.credentialRef.kind                    |string|Credential kind.<br>Allowed value: `secret`                                                                                                           |
|prismCentral.credentialRef.name                    |string|Name of the secret.                                                                                                                                   |
|prismCentral.credentialRef.namespace               |string|(Optional) Namespace of the secret.                                                                                                                   |
|prismCentral.additionalTrustBundle                 |object|Reference to the certificate trust bundle used for Prism Central connection.                                                                          |
|prismCentral.additionalTrustBundle.kind            |string|Kind of the additionalTrustBundle. Allowed value: `ConfigMap`                                                                                         |
|prismCentral.additionalTrustBundle.name            |string|Name of the `ConfigMap` containing the Prism Central trust bundle.                                                                                    |
|prismCentral.additionalTrustBundle.namespace       |string|(Optional) Namespace of the `ConfigMap` containing the Prism Central trust bundle. See [Certificate Trust](./pc_certificates.md) for more information.|
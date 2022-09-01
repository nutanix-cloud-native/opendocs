# Nutanix CCM configuration

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
        }
      },
      "enableCustomLabeling": false,
      "topologyDiscovery": {
        "type": "Categories",
        "topologyCategories": {
          "regionCategory": "${NUTANIX_REGION_CATEGORY}",
          "zoneCategory": "${NUTANIX_ZONE_CATEGORY}"
        }
      }
    }

```

This document will provide an overview of the supported configuration parameters.

### Configuration parameters

| Parameters|||||
|--------------------|------------------|---------|--------------|---------------------------------------------------------------------------------------------------------------------------------------------------|
|topologyDiscovery   |                  |         |              |(Optional) Configures the topology discovery mode.<br>`Prism` topology discovery is used by default if `topologyDiscovery` attribute is not passed.|
|                    |type              |         |              |Topology Discovery mode. Can be `Prism` or `Categories`. See [Topology Discovery](./topology_discovery.md) for more information.                   |
|                    |topologyCategories|         |              |Required if topology discovery mode is `Categories`.<br>                                                                                           |
|                    |                  |         |regionCategory|Category key defining the region of the Kubernetes node.                                                                                           |
|                    |                  |         |zoneCategory  |Category key defining the zone of the Kubernetes node.                                                                                             |
|enableCustomLabeling|                  |         |              |Boolean value to enable custom labeling. See [Custom Labeling](./custom_labeling.md) for more information.<br>Default value is `false`             |
|prismCentral        |                  |         |              |Prism Central endpoint configuration                                                                                                               |
|                    |address           |         |              |FQDN/IP of the Prism Central endpoint                                                                                                              |
|                    |port              |         |              |Port to connect to Prism Central.<br>Default: 9440                                                                                                 |
|                    |insecure          |         |              |Disable Prism Central certificate checking.<br>Default: false                                                                                      |
|                    |credentialRef     |         |              |Prism Central credential configuration. See [Credentials](./ccm_credentials.md) for more information                                               |
|                    |                  |kind     |              |Credential kind.<br>Allowed value: `secret`                                                                                                        |
|                    |                  |name     |              |Name of the secret.                                                                                                                                |
|                    |                  |namespace|              |(Optional) namespace of the Secret.                                                                                                                |
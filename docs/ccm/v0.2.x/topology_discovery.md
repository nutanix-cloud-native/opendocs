# Topology Discovery

One of the responsibilities of the CCM node controller is to annotate and label the nodes in a Kubernetes cluster with toplogy (region and zone) information. The Nutanix Cloud Controller Manager supports following topology discovery methods:

- [Prism](#prism)
- [Categories](#categories)

The topology discovery method can be configured via the `nutanix-config` configmap. See [Nutanix CCM Configuration](./ccm_configuration.md) for more information on the configuration parameters.

## Prism

Prism-based topology discovery is the default mode for Nutanix CCM. In this mode CCM will discover the Prism Element (PE) cluster and Prism Central (PC) instance that host the Kubernetes node VM. Prism Central is configured as the region for the node, while Prism Element is configured as the zone.

Prism-based topology discovery can be configured by omitting the `topologyDiscovery` attribute from the `nutanix-config` configmap or by passing following object:
```JSON   
      "topologyDiscovery": {
        "type": "Prism"
      }
```

### Example
If a Kubernetes Node VM is hosted on PC `my-pc-instance` and PE `my-pe-cluster-1`, Nutanix CCM will assign following labels to the Kubernetes node:

|Key                          |Value          |
|-----------------------------|---------------|
|topology.kubernetes.io/region|my-pc-instance |
|topology.kubernetes.io/zone  |my-pe-cluster-1|

## Categories

The category-based topology discovery mode allows users to assign categories to Prism Element clusters and Kubernetes Node VMs to define a custom topology. Nutanix CCM will hierarchically search for the required categories on the VM/PE.

!!! note

    Categories assigned to the VM object will take precedence over the categories assigned to the PE cluster.

It is required for the categories to exist inside of the PC environment. CCM will not create and assign the categories.
Visit the [Prism Central documentation](https://portal.nutanix.com/page/documents/details?targetId=Prism-Central-Guide-vpc_2022_6:ssp-ssp-categories-manage-pc-c.html){target=_blank} for more information regarding categories.

To enable the Categories topology discovery mode for Nutanix CCM, provide following information in the `topologyDiscovery` attribute:

```JSON
      "topologyDiscovery": {
        "type": "Categories",
        "topologyCategories": {
          "regionCategory": "${NUTANIX_REGION_CATEGORY}",
          "zoneCategory": "${NUTANIX_ZONE_CATEGORY}"
        }
      }
```

### Example

Define a set of categories in PC that will be used for topology discovery:

|Key               |Value                  |
|------------------|-----------------------|
|my-region-category|region-1, region-2     |
|my-zone-category  |zone-1, zone-2, zone-3 |

Assign the categories to the Nutanix entities:

|Nutanix entity |Categories                                            |
|---------------|------------------------------------------------------|
|my-pe-cluster-1|my-region-category:region-1<br>my-zone-category:zone-2|
|my-pe-cluster-2|my-region-category:region-2<br>my-zone-category:zone-3|
|k8s-node-3     |my-region-category:region-2<br>my-zone-category:zone-2|
|k8s-node-4     |my-zone-category:zone-1                               |


Configure CCM to use categories for topology discovery:
```JSON
      "topologyDiscovery": {
        "type": "Categories",
        "topologyCategories": {
          "regionCategory": "my-region-category",
          "zoneCategory": "my-zone-category"
        }
      }
```

!!! example "Scenario 1: Kubernetes node k8s-node-1 is running on my-pe-cluster-1"

        Following topology labels will be assigned to Kubernetes node `k8s-node-1`:

    |Key                          |Value          |
    |-----------------------------|---------------|
    |topology.kubernetes.io/region|region-1       |
    |topology.kubernetes.io/zone  |zone-2         |

    Categories assigned to PE will be used.

!!! example "Scenario 2: Kubernetes node k8s-node-2 is running on my-pe-cluster-2"

    Following topology labels will be assigned to Kubernetes node `k8s-node-2`:

    |Key                          |Value          |
    |-----------------------------|---------------|
    |topology.kubernetes.io/region|region-2       |
    |topology.kubernetes.io/zone  |zone-3         |

    Categories assigned to PE will be used.

!!! example "Scenario 3: Kubernetes node k8s-node-3 is running on my-pe-cluster-2"

    Following topology labels will be assigned to Kubernetes node `k8s-node-3`:

    |Key                          |Value          |
    |-----------------------------|---------------|
    |topology.kubernetes.io/region|region-2       |
    |topology.kubernetes.io/zone  |zone-2         |

    Categories assigned to the VM will be used.

!!! example "Scenario 4: Kubernetes node k8s-node-4 is running on my-pe-cluster-1"

    Following topology labels will be assigned to Kubernetes node `k8s-node-4`:

    |Key                          |Value          |
    |-----------------------------|---------------|
    |topology.kubernetes.io/region|region-1       |
    |topology.kubernetes.io/zone  |zone-1         |

    In this scenario Nutanix CCM will use the value of the `my-zone-category` category that is assigned to the VM. Since the `my-region-category`is not assigned to the VM, Nutanix CCM will search for the category on PE and use the corresponding category value.
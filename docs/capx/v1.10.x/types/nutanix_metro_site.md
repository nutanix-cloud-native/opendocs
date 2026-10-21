# NutanixMetroSite

!!! warning
    The `NutanixMetro`, `NutanixMetroSite` and `NutanixVirtualHADomain` resources are new in CAPX v1.10.x and are intended for Metro / disaster-recovery topologies.

The `NutanixMetroSite` resource identifies a preferred site within a [`NutanixMetro`](./nutanix_metro.md). It selects the preferred [`NutanixFailureDomain`](./nutanix_failure_domains.md) for workload placement and, optionally, labels a group of worker nodes anchored to a topology segment.

Example of a `NutanixMetroSite` resource:

```YAML
apiVersion: infrastructure.cluster.x-k8s.io/v1beta1
kind: NutanixMetroSite
metadata:
  name: "${METRO_SITE_NAME}"
  namespace: "${CLUSTER_NAMESPACE}"
spec:
  metroRef:
    name: "${METRO_NAME}"
  preferredFailureDomain:
    name: "${FAILURE_DOMAIN_A_NAME}"
  # Optional label for a group of worker nodes anchored to a topology segment.
  # groupNameLabel: "site-a"
```

## NutanixMetroSite spec
The table below provides an overview of the supported parameters of the `spec` attribute of a `NutanixMetroSite` resource.

### Configuration parameters

| Key                            |Type  |Description                                                                                       |
|--------------------------------|------|-------------------------------------------------------------------------------------------------|
|metroRef                        |object|**Required.** Reference to the `NutanixMetro` object this site belongs to.                        |
|metroRef.name                   |string|Name of the `NutanixMetro` object in the same namespace.                                          |
|preferredFailureDomain          |object|**Required.** Reference to the preferred `NutanixFailureDomain` object of this metro site.        |
|preferredFailureDomain.name     |string|Name of the preferred `NutanixFailureDomain` object in the same namespace.                        |
|groupNameLabel                  |string|(Optional) Name for a group of worker nodes normally anchored to a topology segment.              |

## Usage Notes

- `metroRef` must reference an existing [`NutanixMetro`](./nutanix_metro.md) in the same namespace.
- `preferredFailureDomain` must reference one of the `NutanixFailureDomain` objects that make up the referenced metro, and identifies the preferred Prism Element cluster for placement.
- `groupNameLabel` is optional and can be used to anchor a group of worker nodes to a topology segment.
- A deletion finalizer (`infrastructure.cluster.x-k8s.io/nutanixmetrosite`) blocks deletion while the object is still referenced.
- The `status.conditions` field reflects the latest observed state of the metro site.

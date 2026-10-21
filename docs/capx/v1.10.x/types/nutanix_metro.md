# NutanixMetro

!!! warning
    The `NutanixMetro`, `NutanixMetroSite` and `NutanixVirtualHADomain` resources are new in CAPX v1.10.x and are intended for Metro / disaster-recovery topologies. Review the [NutanixMetroSite](./nutanix_metro_site.md) and [NutanixVirtualHADomain](./nutanix_virtual_ha_domain.md) resources before using them together.

The `NutanixMetro` resource groups exactly two [`NutanixFailureDomain`](./nutanix_failure_domains.md) resources into a single metro availability zone. It is the top-level object that a [`NutanixMetroSite`](./nutanix_metro_site.md) and a [`NutanixVirtualHADomain`](./nutanix_virtual_ha_domain.md) reference.

Example of a `NutanixMetro` resource:

```YAML
apiVersion: infrastructure.cluster.x-k8s.io/v1beta1
kind: NutanixMetro
metadata:
  name: "${METRO_NAME}"
  namespace: "${CLUSTER_NAMESPACE}"
spec:
  failureDomains:
    - name: "${FAILURE_DOMAIN_A_NAME}"
    - name: "${FAILURE_DOMAIN_B_NAME}"
```

## NutanixMetro spec
The table below provides an overview of the supported parameters of the `spec` attribute of a `NutanixMetro` resource.

### Configuration parameters

| Key                     |Type  |Description                                                                                             |
|-------------------------|------|-------------------------------------------------------------------------------------------------------|
|failureDomains           |list  |References to the two `NutanixFailureDomain` objects that form the metro. **Exactly two** are required. |
|failureDomains.[].name   |string|Name of a `NutanixFailureDomain` object in the same namespace.                                          |

!!! note
    The `failureDomains` list must contain **exactly two** entries (`minItems: 2`, `maxItems: 2`). Each entry references a `NutanixFailureDomain` by `name` in the same namespace.

## Usage Notes

- To use the `NutanixMetro` resource, the Prism Central user configured for CAPX must have the **DR Admin** role (or an equivalent role that includes the required disaster-recovery permissions).
- A `NutanixMetro` pairs two `NutanixFailureDomain` resources, each mapping to a Prism Element cluster, to represent a metro availability zone.
- The referenced `NutanixFailureDomain` objects must exist in the same namespace as the `NutanixMetro`.
- A deletion finalizer (`infrastructure.cluster.x-k8s.io/nutanixmetro`) blocks deletion of a `NutanixMetro` while other resources still reference it.
- The `status.conditions` field reflects the latest observed state of the metro.

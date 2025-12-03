# NutanixFailureDomain

The `NutanixFailureDomain` resource configuration of a CAPX Kubernetes Failure Domain.

Example of a `NutanixFailureDomain` resource:
```YAML
apiVersion: infrastructure.cluster.x-k8s.io/v1beta1
kind: NutanixFailureDomain
metadata:
  name: "${FAILURE_DOMAIN_NAME}"
  namespace: "${CLUSTER_NAMESPACE}"
spec:
  prismElementCluster:
    type: name
    uuid: "${NUTANIX_PRISM_ELEMENT_CLUSTER_NAME}"
  subnets:
    - type: uuid
      uuid: "${NUTANIX_SUBNET_UUID}"
    - type: name
      name: "${NUTANIX_SUBNET_NAME}"
```

## NutanixFailureDomain spec
The table below provides an overview of the supported parameters of the `spec` attribute of a `NutanixFailureDomain` resource.

### Configuration parameters
| Key                                        |Type  |Description                                                                                 |
|--------------------------------------------|------|--------------------------------------------------------------------------------------------|
|prismElementCluster                         |object|Defines the identify the Prism Element cluster in the Prism Central for the failure domain. |
|prismElementCluster.type                    |string|Type to identify the Prism Element cluster. Allowed values: `name` and `uuid`               |
|prismElementCluster.name                    |string|Name of the Prism Element cluster.                                                          |
|prismElementCluster.uuid                    |string|UUID of the Prism Element cluster.                                                          |
|subnets                                     |list  |Reference (name or uuid) to the subnets to be assigned to the VMs.               |
|subnets.[].type                             |string|Type to identify the subnet. Allowed values: `name` and `uuid`                              |
|subnets.[].name                             |string|Name of the subnet.                                                                         |
|subnets.[].uuid                             |string|UUID of the subnet.                                                                         |

!!! note
    The `NutanixFailureDomain` resource allows you to define logical groupings of Nutanix infrastructure for high availability and workload placement in Kubernetes clusters managed by CAPX. Each failure domain maps to a Prism Element cluster and a set of subnets, ensuring that workloads can be distributed across different infrastructure segments.

## Usage Notes

- The `prismElementCluster` field is **required** and must specify either the `name` or `uuid` of the Prism Element cluster.
- The `subnets` field is **required**. You can provide one or more subnets by `name` or `uuid`.
- Failure domains are used by Cluster API to spread machines across different infrastructure segments for resilience.

## Example Scenarios

### Single Subnet by UUID

```yaml
apiVersion: infrastructure.cluster.x-k8s.io/v1beta1
kind: NutanixFailureDomain
metadata:
  name: fd-uuid
spec:
  prismElementCluster:
    type: uuid
    uuid: "00000000-0000-0000-0000-000000000000"
  subnets:
    - type: uuid
      uuid: "11111111-1111-1111-1111-111111111111"
```

### Multiple Subnets by Name

```yaml
apiVersion: infrastructure.cluster.x-k8s.io/v1beta1
kind: NutanixFailureDomain
metadata:
  name: fd-names
spec:
  prismElementCluster:
    type: name
    name: "PrismClusterA"
  subnets:
    - type: name
      name: "SubnetA"
    - type: name
      name: "SubnetB"
```

### Multiple Subnets by Name and UUID

```yaml
apiVersion: infrastructure.cluster.x-k8s.io/v1beta1
kind: NutanixFailureDomain
metadata:
  name: fd-names
spec:
  prismElementCluster:
    type: name
    name: "PrismClusterA"
  subnets:
    - type: name
      name: "SubnetA"
    - type: uuid
      name: "11111111-1111-1111-1111-111111111111"
```
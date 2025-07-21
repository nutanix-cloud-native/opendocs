# Overview

Nutanix CCM provides Cloud Controller Manager functionality to Kubernetes clusters running on the Nutanix AHV hypervisor. Visit the [Kubernetes Cloud Controller Manager](https://kubernetes.io/docs/concepts/architecture/cloud-controller/) documentation for more information about the general design of a Kubernetes CCM.

Nutanix CCM communicates with Prism Central (CCM) to fetch all required information. See the [Requirements](./requirements.md) page for more details.

## Nutanix CCM functionality

|Version|Node Controller|Route Controller|Service Controller|
|-------|---------------|----------------|------------------|
|v0.4.x |Yes            |No              |No                |
|v0.3.x |Yes            |No              |No                |
|v0.2.x |Yes            |No              |No                |


Nutanix CCM specific features:

|Version|[Topology Discovery](./topology_discovery.md)|[Custom Labeling](./custom_labeling.md)|
|-------|---------------------------------------------|---------------------------------------|
|v0.4.x |Prism, Categories                            |Yes                                    |
|v0.3.x |Prism, Categories                            |Yes                                    |
|v0.2.x |Prism, Categories                            |Yes                                    |
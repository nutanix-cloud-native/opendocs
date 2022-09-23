# NutanixMachineTemplate
The `NutanixMachineTemplate` resource defines the configuration of a CAPX Kubernetes VM. 

Example of a `NutanixMachineTemplate` resource.

```YAML
apiVersion: infrastructure.cluster.x-k8s.io/v1beta1
kind: NutanixMachineTemplate
metadata:
  name: "${CLUSTER_NAME}-mt-0"
  namespace: "${NAMESPACE}"
spec:
  template:
    spec:
      providerID: "nutanix://${CLUSTER_NAME}-m1"
      # Supported options for boot type: legacy and uefi
      # Defaults to legacy if not set
      bootType: ${NUTANIX_MACHINE_BOOT_TYPE=legacy}
      vcpusPerSocket: ${NUTANIX_MACHINE_VCPU_PER_SOCKET=1}
      vcpuSockets: ${NUTANIX_MACHINE_VCPU_SOCKET=2}
      memorySize: "${NUTANIX_MACHINE_MEMORY_SIZE=4Gi}"
      systemDiskSize: "${NUTANIX_SYSTEMDISK_SIZE=40Gi}"
      image:
        type: name
        name: "${NUTANIX_MACHINE_TEMPLATE_IMAGE_NAME}"
      cluster:
        type: name
        name: "${NUTANIX_PRISM_ELEMENT_CLUSTER_NAME}"
      subnet:
        - type: name
          name: "${NUTANIX_SUBNET_NAME}"
      # Adds additional categories to the virtual machines.
      # Note: Categories must already be present in Prism Central
      # additionalCategories:
      #   - key: AppType
      #     value: Kubernetes
      # Adds the cluster virtual machines to a project defined in Prism Central.
      # Replace NUTANIX_PROJECT_NAME with the correct project defined in Prism Central
      # Note: Project must already be present in Prism Central.
      # project:
      #   type: name
      #   name: "NUTANIX_PROJECT_NAME"
```

## NutanixMachineTemplate spec
The table below provides an overview of the supported parameters of the `spec` attribute of a `NutanixMachineTemplate` resource.

### Configuration parameters
| Key                                |Type  |Description|
|------------------------------------|------|--------------------------------------------------------------------------------------------------------------|
|bootType                            |string|Boot type of the VM. Depends on the used OS image. Allowed values: `legacy`, `uefi`. Default: `legacy`        |
|vcpusPerSocket                      |int   |Amount of vCPUs per socket. Default: `1`                                                                      |
|vcpuSockets                         |int   |Amount of vCPU sockets. Default: `2`                                                                          |
|memorySize                          |string|Amount of Memory. Default: `4Gi`                                                                              |
|systemDiskSize                      |string|Amount of storage assigned to the system disk. Default: `40Gi`                                                |
|image                               |object|Reference to the OS image used for the system disk                                                            |
|image.type                          |string|Type to identify the OS image. Allowed values: `name` and `uuid`                                              |
|image.name                          |string|Name or UUID of the image                                                                                     |
|cluster                             |object|Reference to the Prism Element cluster                                                                        |
|cluster.type                        |string|Type to identify the Prism Element cluster. Allowed values: `name` and `uuid`                                 |
|cluster.name                        |string|Name or UUID of the Prism Element cluster                                                                     |
|subnets                             |list  |Reference to the subnets to be assigned to the VMs                                                            |
|subnets.[].type                      |string|Type to identify the subnet. Allowed values: `name` and `uuid`                                                |
|subnets.[].name                      |string|Name or UUID of the subnet                                                                                    |
|additionalCategories                |list  |Reference to the categories to be assigned to the VMs. These categories already need to exist in Prism Central|
|additionalCategories.[].key          |string|Key of the category                                                                                           |
|additionalCategories.[].value        |string|Value of the category                                                                                         |
|project                             |object|Reference to the project. This project already needs to exist in Prism Central                                |
|project.type                        |string|Type to identify the project. Allowed values: `name` and `uuid`                                               |
|project.name                        |string|Name or UUID of the project                                                                                   |
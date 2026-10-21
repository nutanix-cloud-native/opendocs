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
      # gpus:
      #  - type: name
      #    name: "GPU NAME"
      # Note: Either of `image` or `imageLookup` must be set, but not both.
      # imageLookup:
      #   format: "NUTANIX_IMAGE_LOOKUP_FORMAT"
      #   baseOS: "NUTANIX_IMAGE_LOOKUP_BASE_OS"
      # dataDisks:
      #   - diskSize:
      #     deviceProperties:
      #       deviceType: Disk
      #       adapterType: SCSI
      #       deviceIndex: 1
      #     storageConfig:
      #       diskMode: Standard
      #       storageContainer:
      #         type: name
      #         name: "NUTANIX_VM_DISK_STORAGE_CONTAINER"
      #     dataSource:
      #       type: name
      #       name: "NUTANIX_DATA_SOURCE_IMAGE_NAME"
```

## NutanixMachineTemplate spec
The table below provides an overview of the supported parameters of the `spec` attribute of a `NutanixMachineTemplate` resource.

### Configuration parameters
| Key                                                |Type  |Description                                                                                             |
|----------------------------------------------------|------|--------------------------------------------------------------------------------------------------------|
|bootType                                            |string|Boot type of the VM. Depends on the OS image used. Allowed values: `legacy`, `uefi`. Default: `legacy`  |
|vcpusPerSocket                                      |int   |Amount of vCPUs per socket. Default: `1`                                                                |
|vcpuSockets                                         |int   |Amount of vCPU sockets. Default: `2`                                                                    |
|memorySize                                          |string|Amount of Memory. Default: `4Gi`                                                                        |
|systemDiskSize                                      |string|Amount of storage assigned to the system disk. Default: `40Gi`                                          |
|image                                               |object|Reference (name or uuid) to the OS image used for the system disk.                                      |
|image.type                                          |string|Type to identify the OS image. Allowed values: `name` and `uuid`                                        |
|image.name                                          |string|Name of the image.                                                                                      |
|image.uuid                                          |string|UUID of the image.                                                                                      |
|cluster                                             |object|(Optional) Reference (name or uuid) to the Prism Element cluster. Name or UUID can be passed            |
|cluster.type                                        |string|Type to identify the Prism Element cluster. Allowed values: `name` and `uuid`                           |
|cluster.name                                        |string|Name of the Prism Element cluster.                                                                      |
|cluster.uuid                                        |string|UUID of the Prism Element cluster.                                                                      |
|subnets                                             |list  |(Optional) Reference (name or uuid) to the subnets to be assigned to the VMs.                           |
|subnets.[].type                                     |string|Type to identify the subnet. Allowed values: `name` and `uuid`                                          |
|subnets.[].name                                     |string|Name of the subnet.                                                                                     |
|subnets.[].uuid                                     |string|UUID of the subnet.                                                                                     |
|additionalCategories                                |list  |Reference to the categories to be assigned to the VMs. These categories already exist in Prism Central. |
|additionalCategories.[].key                         |string|Key of the category.                                                                                    |
|additionalCategories.[].value                       |string|Value of the category.                                                                                  |
|project                                             |object|Reference (name or uuid) to the project. This project must already exist in Prism Central.              |
|project.type                                        |string|Type to identify the project. Allowed values: `name` and `uuid`                                         |
|project.name                                        |string|Name of the project.                                                                                    |
|project.uuid                                        |string|UUID of the project.                                                                                    |
|gpus                                                |object|Reference (name or deviceID) to the GPUs to be assigned to the VMs. Can be vGPU or Passthrough.         |
|gpus.[].type                                        |string|Type to identify the GPU. Allowed values: `name` and `deviceID`                                         |
|gpus.[].name                                        |string|Name of the GPU or the vGPU profile                                                                     |
|gpus.[].deviceID                                    |string|DeviceID of the GPU or the vGPU profile                                                                 |
|imageLookup                                         |object|(Optional) Reference to a container that holds how to look up rhcos images for the cluster.             |
|imageLookup.format                                  |string|Naming format to look up the image for the machine. Default: `capx-{{.BaseOS}}-{{.K8sVersion}}-*`       |
|imageLookup.baseOS                                  |string|Name of the base operating system to use for image lookup.                                              |
|dataDisks                                           |list  |(Optional) Reference to the data disks to be attached to the VM.                                        |
|dataDisks.[].diskSize                               |string|Size (in Quantity format) of the disk attached to the VM. The minimum diskSize is `1GB`.                |
|dataDisks.[].deviceProperties                       |object|(Optional) Reference to the properties of the disk device.                                              |
|dataDisks.[].deviceProperties.deviceType            |string|VM disk device type. Allowed values: `Disk` (default) and `CDRom`                                       |
|dataDisks.[].deviceProperties.adapterType           |string|Adapter type of the disk address.                                                                       |
|dataDisks.[].deviceProperties.deviceIndex           |int   |(Optional) Index of the disk address. Allowed values: non-negative integers (default: `0`)              |
|dataDisks.[].storageConfig                          |object|(Optional) Reference to the storage configuration parameters of the VM disks.                           |
|dataDisks.[].storageConfig.diskMode                 |string|Specifies the disk mode. Allowed values: `Standard` (default) and `Flash`                               |
|dataDisks.[].storageConfig.storageContainer         |object|(Optional) Reference (name or uuid) to the storage_container used by the VM disk.                       |
|dataDisks.[].storageConfig.storageContainer.type    |string|Type to identify the storage container. Allowed values: `name` and `uuid`                               |
|dataDisks.[].storageConfig.storageContainer.name    |string|Name of the storage container.                                                                          |
|dataDisks.[].storageConfig.storageContainer.uuid    |string|UUID of the storage container.                                                                          |
|dataDisks.[].dataSource                             |object|(Optional) Reference (name or uuid) to a data source image for the VM disk.                             |
|dataDisks.[].dataSource.type                        |string|Type to identify the data source image. Allowed values: `name` and `uuid`                               |
|dataDisks.[].dataSource.name                        |string|Name of the data source image.                                                                          |
|dataDisks.[].dataSource.uuid                        |string|UUID of the data source image.                                                                          |

!!! note
  - The `cluster` or `subnets` configuration parameters are optional in case failure domains are defined on the `NutanixCluster` and `MachineDeployment` resources.
  - If the `deviceType` is `Disk`, the valid `adapterType` can be `SCSI`, `IDE`, `PCI`, `SATA` or `SPAPR`. If the `deviceType` is `CDRom`, the valid `adapterType` can be `IDE` or `SATA`.
  - Either of `image` or `imageLookup` must be set, but not both.
  - For a Machine VM, the `deviceIndex` for the disks with the same `deviceType.adapterType` combination should start from `0` and increase consecutively afterwards. Note that for each Machine VM, the `Disk.SCSI.0` and `CDRom.IDE.0` are reserved to be used by the VM's system. So for `dataDisks` of Disk.SCSI and CDRom.IDE, the `deviceIndex` should start from `1`.
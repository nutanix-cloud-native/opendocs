terraform {
  required_providers {
    nutanix = {
      source  = "nutanix/nutanix"
      version = "1.2.0"
    }
  }
}

data "nutanix_cluster" "cluster" {
  name = var.cluster_name
}
data "nutanix_subnet" "subnet" {
  subnet_name = var.subnet_name
}

provider "nutanix" {
  username     = var.user
  password     = var.password
  endpoint     = var.endpoint
  insecure     = true
  wait_timeout = 60
}

# ## Creating BOOTSTRAP VMs here
# resource "nutanix_virtual_machine" "rhocs-bootstrap" {
#   count                = var.vm_bootstrap_count
#   name                 = "${var.vm_bootstrap_prefix}-${count.index + 1}"
#   cluster_uuid         = data.nutanix_cluster.cluster.id
#   num_vcpus_per_socket = "1"
#   num_sockets          = "6"
#   memory_size_mib      = 10*1024
# disk_list {
#   disk_size_bytes = 50 * 1024 * 1024 * 1024
#   device_properties {
#     device_type = "DISK"
#     disk_address = {
#       "adapter_type" = "SCSI"
#       "device_index" = "1"
#     }
#   }
# }

#   nic_list {
#     subnet_uuid = data.nutanix_subnet.subnet.id
#   }
# }

## Creating MASTER VMs here
resource "nutanix_virtual_machine" "rhocs-master" {
  count                = var.vm_master_count
  name                 = "${var.vm_master_prefix}-${count.index + 1}"
  cluster_uuid         = data.nutanix_cluster.cluster.id
  num_vcpus_per_socket = "1"
  num_sockets          = "4"
  memory_size_mib      = 16 * 1024

  disk_list {
    device_properties {
      device_type = "CDROM"
      disk_address = {
        "adapter_type" = "IDE"
        "device_index" = "0"
      }
    }
    data_source_reference = {
      kind = "image"

      uuid = nutanix_image.rhocs.id
    }
  }

  disk_list {
    disk_size_bytes = 100 * 1024 * 1024 * 1024
    device_properties {
      device_type = "DISK"
      disk_address = {
        "adapter_type" = "SCSI"
        "device_index" = "1"
      }
    }
  }

  nic_list {
    subnet_uuid = data.nutanix_subnet.subnet.id
  }
}

## Creating WORKER VMs here
resource "nutanix_virtual_machine" "rhocs-worker" {
  count                = var.vm_worker_count
  name                 = "${var.vm_worker_prefix}-${count.index + 1}"
  cluster_uuid         = data.nutanix_cluster.cluster.id
  num_vcpus_per_socket = "1"
  num_sockets          = "8"
  memory_size_mib      = 16 * 1024

  disk_list {
    device_properties {
      device_type = "CDROM"
      disk_address = {
        "adapter_type" = "IDE"
        "device_index" = "0"
      }
    }
    data_source_reference = {
      kind = "image"

      uuid = nutanix_image.rhocs.id
    }
  }

  disk_list {
    disk_size_bytes = 100 * 1024 * 1024 * 1024
    device_properties {
      device_type = "DISK"
      disk_address = {
        "adapter_type" = "SCSI"
        "device_index" = "1"
      }
    }
  }

  nic_list {
    subnet_uuid = data.nutanix_subnet.subnet.id
  }
}


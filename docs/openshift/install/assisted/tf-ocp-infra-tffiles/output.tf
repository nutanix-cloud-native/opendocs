# output "bootstrap_mac_address" {
#   value = nutanix_virtual_machine.rhocs-bootstrap.*.nic_list
#   description = "Mac address of the bootstrap vm"
# }

output "rhocs_master_mac_address" {
  value = nutanix_virtual_machine.rhocs-master.*.nic_list
  description = "Mac address of the master vms"
}


output "rhocs_worker_mac_address" {
  value = nutanix_virtual_machine.rhocs-worker.*.nic_list
  description = "Mac address of the worker vms"
}

# output "bootstrap_vm_state" {
#   value = nutanix_virtual_machine.rhocs-bootstrap.*.state
#   description = "bootstrap vm state"
# }

output "rhocs_master_vm_state" {
  value = nutanix_virtual_machine.rhocs-master.*.state
  description = "Mac address of the master vms"
}


output "rhocs_worker_vm_state" {
  value = nutanix_virtual_machine.rhocs-worker.*.state
  description = "Mac address of the worker vms"
} 
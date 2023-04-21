variable "PRISMELEMENT_CLUSTERNAME" {
  type = string
}
variable "PRISMELEMENT_NETWORKNAME" {
  type = string
}
variable "NUTANIX_PASSWORD" {
  description = "nutanix cluster password"
  type      = string
  sensitive = true

}
variable "PRISMCENTRAL_ADDRESS" {
  type = string
}

variable "NUTANIX_USERNAME" {
  description = "nutanix cluster username"
  type      = string
  sensitive = true
}

variable "VM_WORKER_PREFIX" { 
}

variable "VM_MASTER_PREFIX" { 
}

variable "VM_MASTER_COUNT" {  
}

variable "VM_WORKER_COUNT" {
}

variable "RHCOS_IMAGE_URI" {
  type = string
}

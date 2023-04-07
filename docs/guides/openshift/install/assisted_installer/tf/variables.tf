variable "cluster_name" {
  type = string
}
variable "subnet_name" {
  type = string
}
variable "password" {
  description = "nutanix cluster password"
  type      = string
  sensitive = true

}
variable "prismcentral" {
  type = string
}

variable "user" {
  description = "nutanix cluster username"
  type      = string
  sensitive = true
}

variable "vm_worker_prefix" { 
}

variable "vm_master_prefix" { 
}

variable "vm_master_count" {  
}

variable "vm_worker_count" {
}

variable "image_uri" {
  type = string
}

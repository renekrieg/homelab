variable "proxmox_node" {
  description = "The Name of the proxmox node."
  default     = "pve-01"
  type        = string
}
variable "proxmox_network_device" {
  type        = string
  default     = "vmbr0"
  description = "Network device used for the cloud-init virtual machines"
}
variable "proxmox_datastore" {
  description = "The ID of the datastore where the resource is stored."
  default     = "local-zfs"
  type        = string
}
variable "nas_datastore" {
  description = "The ID of the datastore where the templates are stored."
  default     = "nas-shared"
  type        = string
}
variable "cloud_init_hostname" {
  description = "The Hostname for the resource."
  default     = "rene"
  type        = string
}
variable "cloud_init_cpu_cores" {
  type        = number
  default     = 2
  description = "Quantity of CPU cores to apply to the cloud-init virtual machines"
}
variable "cloud_init_memory" {
  type        = number
  default     = 2048
  description = "Quantity of memory (megabytes) to apply to the cloud-init virtual machines"
}
variable "cloud_init_datastore" {
  type        = string
  default     = "local-zfs"
  description = "Datastore used for the cloud-init virtual machines"
}
variable "cloud_init_disk_size" {
  type        = string
  default     = "20"
  description = "Quantity of disk space (gigabytes) to apply to the cloud-init virtual machines"
}
variable "cloud_init_vlan_id" {
  type        = number
  default     = 50
  description = "VLAN ID used for the cloud-init nodes"
}
variable "cloud_init_tags" {
  type        = list(any)
  default     = ["terraform", "cloud-init"]
  description = "Tags to apply to the cloud-init virtual machines"
}
variable "cloud_init_debian_vm_id" {
  type        = number
  default     = 9001
  description = "The ID of Cloud-Init Debian template."
}

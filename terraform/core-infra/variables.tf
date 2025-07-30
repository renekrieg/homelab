# Proxmox
variable "proxmox_hostname" {
  # The Talos image is distributed as an XZ archive and the Proxmox API does not allow you to
  # upload an image with that file format. A remote-exec SSH provisoner is used to manage the
  # image in talos_image.tf.
  description = "IP address or hostname of the Proxmox server"
  type        = string
}
variable "proxmox_ssh_key_path" {
  description = "Path to an SSH key used to connect to the Proxmox server"
  type        = string
}
variable "proxmox_ssh_key" {
  description = "Path to an SSH key used to connect to the Proxmox server"
  type        = string
}
variable "user_password" {
  description = "User Password for LXC Container"
  type        = string
  sensitive   = true
}

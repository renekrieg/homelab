data "local_file" "ssh_public_key" {
  filename = "./pve_01.pub"
}

resource "proxmox_virtual_environment_file" "user_data_cloud_config" {
  content_type = "snippets"
  datastore_id = var.nas_datastore
  node_name    = var.proxmox_node

  source_raw {
    data = <<-EOF
    #cloud-config
    local-hostname: debian-vm
    users:
      - default
      - name: rene
        groups:
          - sudo, users
        shell: /bin/bash
        ssh_authorized_keys:
          - ${trimspace(data.local_file.ssh_public_key.content)}
        sudo: ALL=(ALL) NOPASSWD:ALL
    runcmd:
        - apt update
        - apt install -y qemu-guest-agent net-tools
        - timedatectl set-timezone Europe/Berlin
        - systemctl enable qemu-guest-agent
        - systemctl start qemu-guest-agent
        - echo "done" > /tmp/cloud-config.done
    EOF

    file_name = "user-data-cloud-config.yaml"
  }
}


resource "proxmox_virtual_environment_vm" "debian_cloud_init" {
  name      = "debian-cloudinit"
  node_name = var.proxmox_node
  tags      = concat(var.cloud_init_tags, ["debian"])
  started   = false
  template  = true
  vm_id     = var.cloud_init_debian_vm_id

  cpu {
    cores = var.cloud_init_cpu_cores
    type  = "host"
  }

  memory {
    dedicated = var.cloud_init_memory
  }

  operating_system {
    type = "l26"
  }

  serial_device {
    device = "socket"
  }

  agent {
    enabled = true
    # If left to default, Terraform will be held for 15 minutes waiting for the agent to start
    # before it is even installed. Prevent this by effectively immediatly timing out.
    timeout = "1s"
  }

  disk {
    datastore_id = var.cloud_init_datastore
    file_id      = proxmox_virtual_environment_download_file.debian_cloud_image.id
    interface    = "virtio0"
    iothread     = true
    discard      = "on"
    cache        = "writethrough"
    ssd          = true
    size         = var.cloud_init_disk_size
  }

  initialization {
    datastore_id = var.proxmox_datastore
    ip_config {
      ipv4 {
        address = "dhcp"
      }
    }

    user_data_file_id = proxmox_virtual_environment_file.user_data_cloud_config.id
  }

  network_device {
    bridge  = var.proxmox_network_device
    vlan_id = var.cloud_init_vlan_id
  }

}

resource "proxmox_virtual_environment_download_file" "debian_cloud_image" {
  content_type = "iso"
  datastore_id = var.nas_datastore
  node_name    = var.proxmox_node
  file_name    = "debian-12-generic-amd64.qcow2.img"
  url          = "https://cloud-images.ubuntu.com/jammy/current/jammy-server-cloudimg-amd64.img"
}

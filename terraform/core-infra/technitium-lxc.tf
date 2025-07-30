resource "proxmox_virtual_environment_container" "technitium_container" {
  description = "Managed by Terraform"

  node_name = "pve-01"
  vm_id     = 1235

  unprivileged = true

  initialization {
    hostname = "technitium"

    ip_config {
      ipv4 {
        address = "dhcp"
      }
    }

    user_account {
      keys = [
        var.proxmox_ssh_key
      ]
      password = var.user_password
    }
  }

  network_interface {
    name    = "veth0"
    vlan_id = 50
  }

  operating_system {
    template_file_id = proxmox_virtual_environment_download_file.latest_debian_12_standard_lxc_img.id
    # Or you can use a volume ID, as obtained from a "pvesm list <storage>"
    # template_file_id = "local:vztmpl/jammy-server-cloudimg-amd64.tar.gz"
    type = "debian"
  }

  disk {
    datastore_id = "local-zfs"
    size         = 10
  }
  startup {
    order      = "1"
    up_delay   = "60"
    down_delay = "60"
  }
}

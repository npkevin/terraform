terraform {
  required_providers {
    proxmox = {
      source = "bpg/proxmox"
      version = "0.91.0"
    }
  }
}

resource "proxmox_virtual_environment_container" "lxc" {
  # proxmox config
  description = "${var.description}\n"
  tags        = var.tags
  node_name = "proxmox"

  unprivileged = var.unprivileged
  features { nesting = true } # required for docker 

  initialization {
    hostname    = var.name
    user_account {
      # root
      password = "changeme"
      keys     = ["ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAKszs9IEIeH7AluwbOx8hSQKOeOWFPkn3Tm+qRfsYAa root"]
    }
    ip_config {
      ipv4 {
        address = "${var.network_ipv4}/24"
        gateway = var.network_gateway
      }
    }
    dns {
      domain  = "kevnp.lan"
      servers = [var.dns_primary, var.dns_secondary]
    }
  }

  # hardware specifications
  cpu {
    cores  = var.cpu
  }
  memory {
    dedicated = var.memory
    swap = 512
  } 

  # OS Disk
  disk {
    datastore_id = "local-lvm"
    size         = 8
  }
  operating_system {
    template_file_id = proxmox_virtual_environment_download_file.debian_12_lxc_template.id
    type             = "debian"
  }

  dynamic "mount_point" {    
    for_each = var.mountpoints
    content {
      volume = mount_point.value.storage
      path   = mount_point.value.mount
      size   = mount_point.value.size
    }
  }

  network_interface {
    name   = "eth0"
    bridge = "vmbr0"
    firewall = true
  }

  lifecycle {
    ignore_changes = [
    ]
  }
}

resource "proxmox_virtual_environment_download_file" "debian_12_lxc_template" {
  node_name    = "proxmox"
  datastore_id = "raid5"
  url          = "http://download.proxmox.com/images/system/debian-12-standard_12.7-1_amd64.tar.zst"
  file_name    = "debian-12-standard-amd64.tar.zst"
  content_type = "vztmpl"
}

resource "null_resource" "ansible_provision" {
  depends_on = [proxmox_virtual_environment_container.lxc]
  triggers = {
    vm_name = proxmox_virtual_environment_container.lxc.initialization[0].hostname
  }
  provisioner "local-exec" {
    command = <<EOT
    ANSIBLE_CONFIG=~/ansible/ansible.cfg \
    ansible-playbook \
      -l '${self.triggers.vm_name}.kevnp.lan,' \
      ~/ansible/servers/provision.yml
    EOT
  }
}

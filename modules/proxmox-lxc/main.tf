terraform {
  required_providers {
    proxmox = {
      source = "bpg/proxmox"
      version = "0.91.0"
    }
  }
}

locals {
  gpu_enabled = contains([for t in var.tags : lower(t)], "gpu")
  gpu_devices = [
    { path = "/dev/nvidia0", mode = "0666" },
    { path = "/dev/nvidiactl", mode = "0666" },
    { path = "/dev/nvidia-uvm", mode = "0666" },
    { path = "/dev/nvidia-uvm-tools", mode = "0666" },
    { path = "/dev/nvidia-caps/nvidia-cap1", mode = "0400" },
    { path = "/dev/nvidia-caps/nvidia-cap2", mode = "0444" },
  ]
}

resource "proxmox_virtual_environment_container" "lxc" {
  # proxmox config
  description = "${var.description}\n"
  tags        = var.tags
  node_name = "proxmox"

  unprivileged = var.unprivileged
  features {
    nesting = coalesce(try(var.features.nesting, null), true)
    fuse    = try(var.features.fuse, null)
    keyctl  = try(var.features.keyctl, null)
    mount   = try(var.features.mount, null)
  } # nesting is required for docker

  initialization {
    hostname    = var.name
    user_account {
      # root
      password = var.root_password
      keys     = [var.root_public_key]
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
    template_file_id = var.template_id
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

  dynamic "device_passthrough" {
    for_each = local.gpu_enabled ? local.gpu_devices : []
    content {
      path = device_passthrough.value.path
      mode = device_passthrough.value.mode
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

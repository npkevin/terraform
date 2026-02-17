terraform {
  required_providers {
    proxmox = {
      source = "bpg/proxmox"
      version = "0.91.0"
    }
  }
}

locals {
  raid5_enabled = contains([for t in var.tags : lower(t)], "raid5")
}

resource "proxmox_virtual_environment_vm" "lvm" {
  # proxmox config
  name        = var.name
  description = var.description
  tags        = var.tags
  node_name   = "proxmox"
  
  agent { enabled = var.qemu_agent }

  # cloud-init
  initialization {
    datastore_id = "local-lvm"
    interface    = "ide2"
    user_account {
      username = "root"
      password = var.root_password
      keys     = [var.root_public_key]
    }
    ip_config {
      ipv4 {
        address = "${var.cloudinit.ip4_address}/24"
        gateway = var.cloudinit.gateway
      }
    }
    dns {
      domain  = "kevnp.lan"
      servers = [var.cloudinit.dns_primary, var.cloudinit.dns_secondary]
    }
  }

  # hardware specifications
  cpu {
    cores = var.cpu_cores
    type  = "x86-64-v2-AES"
  }
  memory {
    dedicated = var.memory
    floating  = var.memory # equal for ballooning
  } 

  # OS Disk
  disk {
    datastore_id = "local-lvm"
    size         = 16
    interface    = "virtio0"
    import_from  = var.image_id
    file_format  = "qcow2"
    
    backup       = false
    iothread     = true
    discard      = "on"
  }

  # extra disks, mounted via ansible
  dynamic "disk" {
    for_each = var.disks
    content {
      datastore_id  = disk.value.storage
      interface     = disk.key
      file_format   = disk.value.format
      size          = disk.value.size
      backup        = disk.value.backup
      iothread      = disk.value.iothread
    }
  }

  # only maps when raid5 is tagged
  dynamic "virtiofs" {
    for_each = local.raid5_enabled ? [1] : []
    content {
      mapping   = "md0"
      cache     = "always"
      direct_io = true
    }
  }

  network_device {
    bridge = "vmbr0"
    firewall = true
  }

  lifecycle {
    ignore_changes = [
      disk[0].file_format
    ]
  }
}

resource "null_resource" "ansible_provision" {
  depends_on = [proxmox_virtual_environment_vm.lvm]
  triggers = {
    vm_name = proxmox_virtual_environment_vm.lvm.name
  }
  connection {
    type        = "ssh"
    user        = "root"
    private_key = file("~/ansible/roles/base/files/ssh/root")
    host        = proxmox_virtual_environment_vm.lvm.name
  }
  provisioner "remote-exec" {
    inline = [
      "echo 'Waiting for cloud-init...'",
      "cloud-init status --wait > /dev/null"
    ]
  }
  provisioner "local-exec" {
    command = <<EOT
    ANSIBLE_CONFIG=~/ansible/ansible.cfg \
    ansible-playbook \
      -l '${self.triggers.vm_name}.kevnp.lan' \
      -e 'terraform_disks=${jsonencode([
        for key, value in var.disks : {
          slot = key,
          mount = value.mount
        }
      ])}' \
      ~/ansible/servers/provision.yml
    EOT
  }
}

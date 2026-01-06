terraform {
  required_providers {
    proxmox = {
      source = "Telmate/proxmox"
      version = "3.0.2-rc05"
    }
  }
}

# Uploading Cloud-Init Image
# - create vm, set scsi0 to raid5, import image from proxmox/root/deb13.qcow2, convert to template
# proxmox-root:
#   wget https://cloud.debian.org/images/cloud/trixie/latest/debian-13-genericcloud-amd64.qcow2
#   qm create 1000 --name debian13-cloudinit
#   qm set 1000 --scsi0 raid5:0,import-from=/root/debian-13-genericcloud-amd64.qcow2
#   qm template 1000

#  https://registry.terraform.io/providers/Telmate/proxmox/latest/docs/resources/vm_qemu
resource "proxmox_vm_qemu" "lvm" {
  # proxmox config
  name        = var.name
  description = var.description
  tags        = join(",", var.tags)
  
  clone       = var.template
  target_node = "proxmox"
  scsihw      = "virtio-scsi-single"
  agent       = 1

  # cloudinit
  ciuser     = "root"
  sshkeys    = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAKszs9IEIeH7AluwbOx8hSQKOeOWFPkn3Tm+qRfsYAa root"
  cicustom   = "vendor=local:snippets/qemu-guest-agent.yml" # proxmox-root:/var/lib/vz/snippets/qemu-guest-agent.yml
  nameserver = "${var.cloudinit.dns_primary} ${var.cloudinit.dns_secondary}"
  ipconfig0  = "ip=${var.cloudinit.ip4_address}/24,gw=${var.cloudinit.gateway}"
  skip_ipv6  = true
  ciupgrade  = true

  # cloud-init cdrom
  disk {
    slot    = "ide2"
    type    = "cloudinit"
    storage = "raid5"
  }

  # hardware specifications
  cpu { cores = var.cpu_cores }
  memory      = var.memory

  # root/system disk
  boot      = "order=scsi0" 
  disk {
    slot    = "scsi0"
    type    = "disk"
    storage = "raid5"
    size    = "16G"
    format  = "raw" # tf complains
  }

  # extra disks, mounted via ansible
  dynamic "disk" {
    for_each = var.disks
    content {
      slot     = disk.key
      size     = disk.value.size
      storage  = disk.value.storage
      type     = disk.value.type
      format   = disk.value.format
      backup   = disk.value.backup
      iothread = disk.value.iothread
    }
  }

  network {
    id       = 0
    bridge   = "vmbr0"
    model    = "virtio"
    firewall = true
  }

  lifecycle {
    ignore_changes = [
      onboot,
      startup,
      cpu[0].affinity,
    ]
  }
}

resource "null_resource" "ansible_provision" {
  depends_on = [proxmox_vm_qemu.lvm]
  triggers = { # todo: do i really needs all of these triggers?
    vm_name = proxmox_vm_qemu.lvm.name
    vm_id   = proxmox_vm_qemu.lvm.id
    vm_ip   = proxmox_vm_qemu.lvm.default_ipv4_address
  }
  connection {
    type        = "ssh"
    user        = "root"
    private_key = file("~/ansible/roles/base/files/ssh/root")
    host        = proxmox_vm_qemu.lvm.name
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

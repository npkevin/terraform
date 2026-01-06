terraform {
  required_providers {
    proxmox = {
      source  = "Telmate/proxmox"
      version = "3.0.2-rc05"
    }
  }
}

resource "proxmox_lxc" "lxc" {
  # proxmox config
  hostname    = var.name
  description = "${var.description}\n"
  tags        = join(",", var.tags)
  
  ostemplate   = var.template 
  target_node = "proxmox"
  unprivileged = var.unprivileged
  start        = true
  onboot       = true

  # hardware specifications
  cores  = var.cpu
  memory = var.memory
  swap   = 512

  rootfs {
    storage = var.root_storage
    size    = var.root_size
  }

  dynamic "mountpoint" {    
    for_each = { for index, mp in var.mountpoints : index => mp }
    content {
      key     = mountpoint.key           # use index
      slot    = tostring(mountpoint.key) # use index
      storage = mountpoint.value.storage
      size    = mountpoint.value.size
      mp      = mountpoint.value.mount
    }
  }

  network {
    name   = "eth0"
    bridge = "vmbr0"
    ip     = "${var.network_ipv4}/24" # CIDR format
    gw     = var.network_gateway
    firewall = true
  }
  
  nameserver   = "${var.dns_primary} ${var.dns_secondary}"
  ssh_public_keys = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAKszs9IEIeH7AluwbOx8hSQKOeOWFPkn3Tm+qRfsYAa root"
  password        = "changeme"

  features {
    nesting = true # required for docker
  }

  lifecycle {
    ignore_changes = [
      network,
      target_node,
    ]
  }
}

resource "null_resource" "ansible_provision" {
  depends_on = [proxmox_lxc.lxc]
  triggers = {
    host = "${proxmox_lxc.lxc.hostname}.kevnp.lan"
  }
  provisioner "local-exec" {
    environment = {
      ANSIBLE_CONFIG = "~/ansible/ansible.cfg"
    }
    # todo: dynamic zone names (kevnp.lan)
    command = <<EOT
      ansible-playbook \
        -l '${self.triggers.host},' \
        ~/ansible/servers/provision.yml
    EOT
  }
}

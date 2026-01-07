module "lvm" {
  source    = "./modules/proxmox-lvm"
  for_each  = var.proxmox_lvm

  name        = each.key
  description = each.value.description
  tags        = each.value.tags

  cpu_cores   = each.value.config.cpu
  memory      = each.value.config.memory
  disks       = each.value.config.disks

  cloudinit   = each.value.config.cloudinit
}

module "lxc" {
  source    = "./modules/proxmox-lxc"
  for_each  = var.proxmox_lxc

  name            = each.key
  description     = each.value.description
  tags            = each.value.tags
  unprivileged    = each.value.unprivileged

  cpu             = each.value.cpu
  memory          = each.value.memory
  mountpoints     = each.value.mountpoints

  network_ipv4     = each.value.network_ipv4
  network_gateway = each.value.network_gateway
  dns_primary     = each.value.dns_primary
  dns_secondary   = each.value.dns_secondary
}

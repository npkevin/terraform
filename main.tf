terraform {
  required_providers {
    proxmox = {
      source = "Telmate/proxmox"
      version = "3.0.2-rc05"
    }
  }
}

provider "proxmox" {
  pm_api_url          = "https://192.168.2.100:8006/api2/json"
  pm_api_token_id     = "terraform@pve!terraform"
  pm_api_token_secret = "dfa4c007-7332-45c5-995a-bb03a78e85f3"
  pm_tls_insecure     = true
}

module "lvm" {
  source    = "./modules/proxmox-lvm"
  for_each  = var.proxmox_lvm

  name        = each.key
  description = each.value.description
  template    = each.value.template
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
  template        = each.value.template
  tags            = each.value.tags

  cpu             = each.value.cpu
  memory          = each.value.memory
  mountpoints     = each.value.mountpoints

  network_ipv4     = each.value.network_ipv4
  network_gateway = each.value.network_gateway
  dns_primary     = each.value.dns_primary
  dns_secondary   = each.value.dns_secondary
}

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

module "vm" {
  source    = "./modules/proxmox"
  for_each  = var.proxmox_vms

  name        = each.key
  description = each.value.description
  template    = each.value.template
  tags        = each.value.tags

  cpu_cores   = each.value.config.cpu
  memory      = each.value.config.memory
  disks       = each.value.config.disks

  cloudinit   = each.value.config.cloudinit
}

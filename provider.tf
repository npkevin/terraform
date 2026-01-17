provider "proxmox" {
  endpoint = var.proxmox_api.endpoint
  username = var.proxmox_api.username
  password = var.proxmox_api.password
  insecure = var.proxmox_api.insecure
}

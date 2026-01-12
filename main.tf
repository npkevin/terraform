resource "proxmox_virtual_environment_download_file" "debian_13_trixie_qcow2" {
  node_name    = "proxmox"
  datastore_id = "raid5"
  url          = "https://cloud.debian.org/images/cloud/trixie/latest/debian-13-genericcloud-amd64.qcow2"
  file_name    = "debian-13-genericcloud-amd64.qcow2"
  content_type = "import"
}

resource "proxmox_virtual_environment_download_file" "debian_12_lxc_template" {
  node_name    = "proxmox"
  datastore_id = "raid5"
  url          = "http://download.proxmox.com/images/system/debian-12-standard_12.7-1_amd64.tar.zst"
  file_name    = "debian-12-standard-amd64.tar.zst"
  content_type = "vztmpl"
}

module "lvm" {
  source    = "./modules/proxmox-lvm"
  for_each  = var.proxmox_lvm

  name        = each.key
  description = each.value.description
  tags        = each.value.tags
  qemu_agent  = each.value.qemu_agent

  cpu_cores   = each.value.config.cpu
  memory      = each.value.config.memory
  disks       = each.value.config.disks

  cloudinit   = each.value.config.cloudinit

  image_id = proxmox_virtual_environment_download_file.debian_13_trixie_qcow2.id
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

  template_id = proxmox_virtual_environment_download_file.debian_12_lxc_template.id
}

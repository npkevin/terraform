proxmox_vms = {
  minecraft = {
    description = "Minecraft"
    template    = "debian13-cloudinit"
    tags        = "debian"
    config = {
      cpu    = 4
      memory = 16384
      disks = {
        scsi1 = { size = "64G" } # data
      }
      cloudinit = {
        ip4_address = "192.168.2.220/24"
      }
    }
  }

  labxadm1 = { # 📍
    description = "Administrator 1"
    template    = "debian13-cloudinit"
    tags        = "debian"
    config = {
      cpu    = 4
      memory = 8192
      cloudinit = {
        ip4_address = "192.168.2.201/24"
      }
    }
  }
  labxadm2 = { # 📍
    description = "Administrator 2"
    template    = "debian13-cloudinit"
    tags        = "debian"
    config = {
      cpu    = 4
      memory = 8192
      cloudinit = {
        ip4_address = "192.168.2.202/24"
      }
    }
  }
  medxarr = {
    description = "Media Management Server for *arr environment"
    template    = "debian13-cloudinit"
    tags        = "debian"
    config = {
      cpu    = 4
      memory = 4048
      disks = {
        scsi1 = { size = "64G" } # configs
      }
      cloudinit = {
        ip4_address = "192.168.2.151/24"
      }
    }
  }
  medxxrr = {
    description = "Media Management Server for *arr environment"
    template    = "debian13-cloudinit"
    tags        = "debian"
    config = {
      cpu    = 4
      memory = 4048
      disks = {
        scsi1 = { size = "64G" } # configs
      }
      cloudinit = {
        ip4_address = "192.168.2.152/24"
      }
    }
  }
  stoxnas = {
    description = "NAS"
    template    = "debian13-cloudinit"
    tags        = "debian"
    config = {
      cpu    = 4
      memory = 8096
      cloudinit = {
        ip4_address = "192.168.2.60/24"
      }
    }
  }
  netxdns = {
    description = "DNS Server"
    template    = "debian13-cloudinit"
    tags        = "debian"
    config = {
      cpu    = 1
      memory = 512
      cloudinit = {
        ip4_address = "192.168.2.110/24"
      }
    }
  }
}

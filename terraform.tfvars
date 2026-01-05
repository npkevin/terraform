proxmox_lvm = {
  minecraft = {
    description = "Minecraft"
    template    = "debian13-cloudinit"
    tags        = "debian"
    config = {
      cpu    = 4
      memory = 32768
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
  stoxnas = { # delme
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
  netxdns = { # delme
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

proxmox_lxc = {
  stoxnas = {
    description  = "NAS"
    template     = "local:vztmpl/debian-13-standard_13.1-2_amd64.tar.zst"
    tags         = "debian"

    cpu          = 4
    memory       = 8096
    network_ipv4 = "192.168.2.60"
  },
  netxdns = {
    description  = "DNS Server"
    template     = "local:vztmpl/debian-13-standard_13.1-2_amd64.tar.zst"
    tags         = "debian"

    network_ipv4 = "192.168.2.110"
  }
}

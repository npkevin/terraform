proxmox_lvm = {
  labxadm1 = { # 📍
    description = "Administrator 1"
    template    = "debian13-cloudinit"
    tags        = ["lvm-debian"]
    # qemu_agent  = true
    config = {
      cpu    = 4
      memory = 8192
      cloudinit = {
        ip4_address = "192.168.2.201"
      }
    }
  }
  labxadm2 = { # 📍
    description = "Administrator 2"
    template    = "debian13-cloudinit"
    tags        = ["lvm-debian"]
    config = {
      cpu    = 4
      memory = 8192
      cloudinit = {
        ip4_address = "192.168.2.202"
      }
    }
  }
  medxarr = {
    description = "Media Management Server for *arr environment"
    template    = "debian13-cloudinit"
    tags        = ["lvm-debian", "raid5"]
    qemu_agent  = true
    config = {
      cpu    = 4
      memory = 4048
      disks = { # configs
        scsi1 = {
          size    = 64
          mount   = "/mnt/app"
        }
      }
      cloudinit = {
        ip4_address = "192.168.2.151"
      }
    }
  }
  stoxnas = {
    description = "Network Attached Storage"
    template    = "debian13-cloudinit"
    tags        = ["lvm-debian", "raid5"]
    qemu_agent  = true
    config = {
      cpu    = 4
      memory = 4096
      cloudinit = {
        ip4_address = "192.168.2.60"
      }
    }
  }
}

proxmox_lxc = {
  medxjelly = {
    description  = "Jellyfin Server"
    template     = "local:vztmpl/debian-13-standard_13.1-2_amd64.tar.zst"
    tags         = ["media", "gpu"]
    unprivileged = false
    cpu          = 4
    memory       = 4096
    mountpoints = [
      { storage = "/mnt/md0/Library", size = null,  mount = "/mnt/library" }, # null for directory
      { storage = "appdata",          size = "16G", mount = "/mnt/data" },
    ]
    network_ipv4 = "192.168.2.150"
  }
  netxdns = {
    description  = "DNS Server"
    template     = "local:vztmpl/debian-13-standard_13.1-2_amd64.tar.zst"
    tags         = ["network"]
    network_ipv4 = "192.168.2.110"
  }
  netxedge = {
    description  = "Network Edge Server"
    template     = "local:vztmpl/debian-13-standard_13.1-2_amd64.tar.zst"
    tags         = ["media", "network"]
    network_ipv4 = "192.168.2.111"
  }
}

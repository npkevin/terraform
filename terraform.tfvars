proxmox_lvm = {
  minecraft = {
    description = "Minecraft"
    template    = "debian13-cloudinit"
    tags        = ["debian", "lvm"]
    config = {
      cpu    = 4
      memory = 32768
      disks = { # world data
        scsi1 = {
          size    = 64
          storage = "appdata"
          format  = "qcow2"
          mount   = "/mnt/app"
        } 
      }
      cloudinit = {
        ip4_address = "192.168.2.220"
      }
    }
  }
  labxadm1 = { # 📍
    description = "Administrator 1"
    template    = "debian13-cloudinit"
    tags        = ["debian", "lvm"]
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
    tags        = ["debian", "lvm"]
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
    tags        = ["debian", "lvm"]
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
    tags        = ["debian", "lvm", "raid5"]
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
  # stoxnas = {
  #   description  = "NAS"
  #   template     = "local:vztmpl/debian-13-standard_13.1-2_amd64.tar.zst"
  #   tags         = ["debian", "lxc"]
  #   unprivileged = false
  #   cpu          = 4
  #   memory       = 8096
  #   mountpoints = [
  #     # tf apply, then edit manually or else you get storage = "/mnt/md0:0"
  #     # root@proxmox:~# nano /etc/pve/lxc/103.conf
  #     { storage = "/mnt/md0", size = "0T", mount = "/mnt/md0" },
  #   ]
  #   network_ipv4 = "192.168.2.60"
  # },
  netxdns = {
    description  = "DNS Server"
    template     = "local:vztmpl/debian-13-standard_13.1-2_amd64.tar.zst"
    tags         = ["debian", "lxc"]
    network_ipv4 = "192.168.2.110"
  }
}

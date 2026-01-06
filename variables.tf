variable proxmox_lvm {
  type = map(object({
    # todo: add domain = "kevnp.lan"
    description = optional(string, "Terraform Managed Virtual Machine")
    template    = string
    tags        = optional(list(string), [])
    config = object({
      cpu       = number
      memory    = number

      disks = optional(map(object({
        type    = optional(string)  
        storage = optional(string)
        format  = optional(string)
        size    = optional(string)
        mount   = optional(string)
      })), {})

      cloudinit = object({
        ip4_address   = string
        gateway       = optional(string, "192.168.2.1")
        dns_primary   = optional(string, "192.168.2.110")
        dns_secondary = optional(string, "1.1.1.1")
      })
    })
  }))
}

variable proxmox_lxc {
  type = map(object({
    # todo: add domain = "kevnp.lan"
    description = optional(string, "Terraform Managed Virtual Machine")
    template    = string
    tags        = optional(list(string), [])

    cpu       = optional(number)
    memory    = optional(number)

    network_ipv4     = string
    network_gateway = optional(string, "192.168.2.1")
    dns_primary     = optional(string, "192.168.2.110")
    dns_secondary   = optional(string, "1.1.1.1")

    mountpoints = optional(map(object({
      type    = optional(string)  
      storage = optional(string)
      size    = string
    })), {})
  }))
}
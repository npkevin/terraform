variable proxmox_vms {
  type = map(object({
    # todo: add domain = "kevnp.lan"
    description = optional(string, "Terraform Managed Virtual Machine")
    template    = string
    tags        = optional(string, "")
    config = object({
      cpu       = number
      memory    = number

      disks = optional(map(object({
        type    = optional(string)  
        storage = optional(string)
        size    = string
      })), {})

      cloudinit = object({
        ip4_address   = optional(string)
        gateway       = optional(string, "192.168.2.1")
        dns_primary   = optional(string, "192.168.2.110")
        dns_secondary = optional(string, "1.1.1.1")
      })
    })
  }))
}

variable name        { type = string }
variable description { type = string }
variable template    { type = string }
variable tags        { type = list(string) }

# variable domain      { type = string }

variable cpu_cores {
  type = number
  default = 2
}
variable memory    {
  type = number
  default = 512
}

variable disks {
  type = map(object({
    size    = optional(string, "32G")
    storage = optional(string, "raid5")
    type    = optional(string, "disk")
    format  = optional(string, "raw") # tf complains
    backup   = optional(bool, false)
    iothread = optional(bool, true)
    mount    = optional(string)
  }))
  default = {}
}

variable cloudinit {
  type = object({
    ip4_address   = optional(string, "dhcp")
    gateway       = string
    dns_primary   = string
    dns_secondary = string
  })
}

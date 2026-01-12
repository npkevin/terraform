variable name        { type = string }
variable description { type = string }
variable tags        { type = list(string) }

# variable domain      { type = string }

variable image_id {
  type = string
}

variable qemu_agent {
  type = bool
  default = false
}

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
    size    = optional(number, 32)
    storage = optional(string, "raid5")
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

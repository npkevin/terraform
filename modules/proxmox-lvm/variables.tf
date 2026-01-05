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
    size    = string
    storage = optional(string, "raid5") # e.g. "raid5"
    type    = optional(string, "disk")
    format  = optional(string, "raw") # tf complains
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

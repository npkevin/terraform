variable name        { type = string }
variable description { type = string }
variable template    { type = string } # use full path: "local:vztmpl/debian-12..."
variable tags        { type = string }

variable cpu {
  type    = number
  default = 1
}

variable memory {
  type    = number
  default = 512
}

# network
variable network_ipv4 { type = string }
variable network_gateway { type = string }
variable dns_primary { type = string }
variable dns_secondary { type = string }

variable root_storage {
  type    = string
  default = "local-lvm" 
}

variable root_size {
  type    = string
  default = "8G"
}

variable mountpoints {
  type = map(object({
    storage = optional(string, "local-lvm")
    size    = optional(string, "8G")
    mp      = optional(string, "/mnt/data")
  }))
  default = {}
}
variable name        { type = string }
variable description { type = string }
variable tags        { type = list(string) }

variable unprivileged {
  type = bool
  default = true
}

variable template_id {
  type = string
}

variable cpu {
  type    = number
  default = 1
}

variable memory {
  type    = number
  default = 512
}

# network
variable network_ipv4    { type = string }
variable network_gateway { type = string }
variable dns_primary     { type = string }
variable dns_secondary   { type = string }

variable mountpoints {
  type = list(object({
    storage = string
    size    = string
    mount   = string
  }))
  default = []
}

variable features {
  type = object({
    nesting = optional(bool)
    fuse    = optional(bool)
    keyctl  = optional(bool)
    mount   = optional(list(string))
  })
  default = {
    nesting = true
  }
}

variable root_password {
  type      = string
  sensitive = true
}

variable root_public_key {
  type = string
}

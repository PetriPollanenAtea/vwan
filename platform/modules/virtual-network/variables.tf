variable "name" {
  description = "Name of the Virtual Network."
  type        = string

  validation {
    condition     = length(trimspace(var.name)) > 0
    error_message = "The Virtual Network name must not be empty."
  }
}

variable "resource_group_name" {
  description = "Resource group containing the Virtual Network."
  type        = string
}

variable "location" {
  description = "Azure region of the Virtual Network."
  type        = string
}

variable "address_space" {
  description = "Address spaces assigned to the Virtual Network."
  type        = list(string)

  validation {
    condition     = length(var.address_space) > 0
    error_message = "At least one address space must be defined."
  }
}

variable "dns_servers" {
  description = "Optional custom DNS servers."
  type        = list(string)
  default     = []
}

variable "subnets" {
  description = "Subnets created in the Virtual Network."

  type = map(object({
    name             = string
    address_prefixes = list(string)

    service_endpoints = optional(
      list(string),
      []
    )

    private_endpoint_network_policies = optional(
      string,
      "Enabled"
    )

    private_link_service_network_policies_enabled = optional(
      bool,
      true
    )

    delegations = optional(map(object({
      name = string

      service_delegation = object({
        name = string

        actions = optional(
          list(string),
          []
        )
      })
    })), {})
  }))

  validation {
    condition     = length(var.subnets) > 0
    error_message = "At least one subnet must be defined."
  }

  validation {
    condition = alltrue([
      for subnet in values(var.subnets) :
      length(subnet.address_prefixes) > 0
    ])

    error_message = "Every subnet must have at least one address prefix."
  }
}

variable "tags" {
  description = "Tags assigned to the Virtual Network."
  type        = map(string)
  default     = {}
}
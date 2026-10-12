variable "name" {
  description = "Name of the Virtual Hub connection."
  type        = string

  validation {
    condition     = length(trimspace(var.name)) > 0
    error_message = "The Virtual Hub connection name must not be empty."
  }
}

variable "virtual_hub_id" {
  description = "Resource ID of the target Virtual Hub."
  type        = string

  validation {
    condition     = length(trimspace(var.virtual_hub_id)) > 0
    error_message = "The Virtual Hub ID must not be empty."
  }
}

variable "remote_virtual_network_id" {
  description = "Resource ID of the connected Virtual Network."
  type        = string

  validation {
    condition     = length(trimspace(var.remote_virtual_network_id)) > 0
    error_message = "The remote Virtual Network ID must not be empty."
  }
}

variable "internet_security_enabled" {
  description = "Whether internet security is enabled for the connection."
  type        = bool
  default     = false
}
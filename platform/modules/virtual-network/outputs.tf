output "id" {
  description = "Virtual Network resource ID."
  value       = azurerm_virtual_network.this.id
}

output "name" {
  description = "Virtual Network name."
  value       = azurerm_virtual_network.this.name
}

output "resource_group_name" {
  description = "Virtual Network resource group."
  value       = azurerm_virtual_network.this.resource_group_name
}

output "location" {
  description = "Virtual Network Azure region."
  value       = azurerm_virtual_network.this.location
}

output "subnet_ids" {
  description = "Map of subnet configuration keys to subnet IDs."

  value = {
    for subnet_key, subnet in azurerm_subnet.this :
    subnet_key => subnet.id
  }
}

output "subnets" {
  description = "Created subnet information."

  value = {
    for subnet_key, subnet in azurerm_subnet.this :
    subnet_key => {
      id               = subnet.id
      name             = subnet.name
      address_prefixes = subnet.address_prefixes
    }
  }
}
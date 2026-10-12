output "id" {
  description = "Virtual Hub connection resource ID."
  value       = azurerm_virtual_hub_connection.this.id
}

output "name" {
  description = "Virtual Hub connection name."
  value       = azurerm_virtual_hub_connection.this.name
}

output "virtual_hub_id" {
  description = "Connected Virtual Hub ID."
  value       = azurerm_virtual_hub_connection.this.virtual_hub_id
}

output "remote_virtual_network_id" {
  description = "Connected Virtual Network ID."
  value       = azurerm_virtual_hub_connection.this.remote_virtual_network_id
}
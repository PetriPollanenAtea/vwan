locals {
  firewall_policy_ids = {
    global   = data.azurerm_firewall_policy.global.id
    americas = data.azurerm_firewall_policy.americas.id
    emea     = data.azurerm_firewall_policy.emea.id
  }
}
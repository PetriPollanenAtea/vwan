data "azurerm_firewall_policy" "global" {
  resource_group_name = "rg-petrip"
  name                = "azfw-pol-global"
}

data "azurerm_firewall_policy" "americas" {
  resource_group_name = "rg-petrip"
  name                = "azfw-pol-americas"
}

data "azurerm_firewall_policy" "emea" {
  resource_group_name = "rg-petrip"
  name                = "azfw-pol-emea"
}

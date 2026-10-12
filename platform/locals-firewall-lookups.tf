locals {
  firewall_ids = {
    for key, firewall
    in azurerm_firewall.this :
    key => firewall.id
  }
}
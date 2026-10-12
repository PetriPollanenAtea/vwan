locals {
  vpn_gateway_ids = {
    for hub_key, gateway in azurerm_vpn_gateway.this :
    hub_key => gateway.id
  }
}
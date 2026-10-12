output "vpn_gateways" {
  value = {
    for hub_key, gateway in azurerm_vpn_gateway.this :
    hub_key => {
      id             = gateway.id
      name           = gateway.name
      location       = gateway.location
      virtual_hub_id = gateway.virtual_hub_id
      scale_unit     = gateway.scale_unit
    }
  }
}
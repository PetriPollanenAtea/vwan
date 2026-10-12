output "vpn_gateway_connections" {
  description = "Created Virtual WAN VPN Gateway Connections."

  value = {
    for connection_key, connection
    in azurerm_vpn_gateway_connection.this :
    connection_key => {
      id                 = connection.id
      name               = connection.name
      vpn_gateway_id     = connection.vpn_gateway_id
      remote_vpn_site_id = connection.remote_vpn_site_id
    }
  }
}
locals {
  /*
   * Load configuration files.
   */
  virtual_hub_connections_config = yamldecode(
    file(var.virtual_hub_connections_configuration_file)
  )

  /*
   * Normalize the VNet-to-vHub connections.
   */
  virtual_hub_connections = {
    for connection_key, connection in try(
      local.virtual_hub_connections_config.virtual_hub_connections,
      {}
    ) :
    connection_key => {
      name            = connection.name
      virtual_hub     = connection.virtual_hub
      virtual_network = connection.virtual_network

      internet_security_enabled = try(
        connection.internet_security_enabled,
        false
      )
    }
  }
}
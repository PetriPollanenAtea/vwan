locals {
  /*
   * Load configuration files.
   */
  virtual_wan_config = yamldecode(
    file(var.virtual_wan_configuration_file)
  )

  /*
   * Normalize Virtual WAN.
   */
  virtual_wan = local.virtual_wan_config.virtual_wan

  /*
   * Normalize regional Virtual Hubs.
   */
  virtual_hubs = {
    for hub_key, hub in try(
      local.virtual_wan_config.virtual_hubs,
      {}
    ) :
    hub_key => {
      name                = hub.name
      resource_group_name = hub.resource_group_name
      location            = hub.location
      address_prefix      = hub.address_prefix
      sku                 = try(hub.sku, "Standard")
      hub_routing_preference = try(
        hub.hub_routing_preference,
        "VpnGateway"
      )
      routing_intent = try(
        hub.routing_intent,
        {}
      )
      tags = try(hub.tags, {})
    }
  }
}
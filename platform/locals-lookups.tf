locals {
  /*
   * IDs of VNets created by this Terraform root module.
  */
  managed_virtual_network_ids = {
    for vnet_key, vnet in module.virtual_network :
    vnet_key => vnet.id
  }

  /*
   * IDs supplied through existing-virtual-networks.yml.
  */
  existing_virtual_network_ids = {
    for vnet_key, vnet in local.existing_virtual_networks :
    vnet_key => vnet.resource_id
  }

  /*
   * Unified lookup used by the Virtual Hub connection module.
  */
  all_virtual_network_ids = merge(
    local.managed_virtual_network_ids,
    local.existing_virtual_network_ids
  )

  virtual_hub_ids = {
    for hub_key, hub in azurerm_virtual_hub.this :
    hub_key => hub.id
  }
}

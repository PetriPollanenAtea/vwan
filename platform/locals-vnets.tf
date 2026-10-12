locals {
  /*
   * Load configuration files.
   */
  virtual_networks_config = yamldecode(
    file(var.virtual_networks_configuration_file)
  )

  existing_virtual_networks_config = yamldecode(
    file(var.existing_virtual_networks_configuration_file)
  )

  /*
   * Normalize Managed Virtual Networks.
   */
  virtual_networks = {
    for vnet_key, vnet in try(
      local.virtual_networks_config.virtual_networks,
      {}
    ) :
    vnet_key => {
      name                = vnet.name
      resource_group_name = vnet.resource_group_name
      location            = vnet.location
      address_space       = vnet.address_space
      dns_servers         = try(vnet.dns_servers, [])
      tags                = try(vnet.tags, {})

      subnets = {
        for subnet_key, subnet in vnet.subnets :
        subnet_key => {
          name             = subnet.name
          address_prefixes = subnet.address_prefixes

          service_endpoints = try(
            subnet.service_endpoints,
            []
          )

          private_endpoint_network_policies = try(
            subnet.private_endpoint_network_policies,
            "Enabled"
          )

          private_link_service_network_policies_enabled = try(
            subnet.private_link_service_network_policies_enabled,
            true
          )

          delegations = try(
            subnet.delegations,
            {}
          )
        }
      }
    }
  }

  /*
   * Existing Virtual Networks.
   *
   * Terraform does not create or manage these VNets.
   * It only consumes their resource IDs.
  */
  existing_virtual_networks = {
    for vnet_key, vnet in try(
      local.existing_virtual_networks_config.existing_virtual_networks,
      {}
    ) :
    vnet_key => {
      resource_id = vnet.resource_id
    }
  }
}
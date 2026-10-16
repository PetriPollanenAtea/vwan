locals {
  /*
   * One Public IP Prefix per Azure Firewall.
   *
   * Region and resource group are taken from the firewall's
   * referenced Virtual Hub.
   */
  firewall_public_ip_prefixes = {
    for firewall_key, firewall
    in local.firewalls :

    firewall_key => {
      firewall_key = firewall_key
      hub_key      = firewall.hub

      name = firewall.public_ip_prefix.name

      prefix_length = (
        firewall.public_ip_prefix.prefix_length
      )

      firewall_ip_count = (
        firewall.public_ip_prefix.firewall_ip_count
      )

      resource_group_name = try(
        local.virtual_hubs[
          firewall.hub
        ].resource_group_name,
        null
      )

      location = try(
        local.virtual_hubs[
          firewall.hub
        ].location,
        null
      )
    }
  }

  /*
   * Expand every prefix into the number of individual
   * Public IP resources requested for the firewall.
   */
  firewall_public_ips = merge([
    for firewall_key, prefix
    in local.firewall_public_ip_prefixes : {

      for index in range(
        try(prefix.firewall_ip_count, 0)
      ) :

      "${firewall_key}/${index}" => {
        firewall_key = firewall_key
        hub_key      = prefix.hub_key
        index        = index

        name = format(
          "pip-%s-%02d",
          firewall_key,
          index + 1
        )

        resource_group_name = (
          prefix.resource_group_name
        )

        location = prefix.location
      }
    }
  ]...)

}
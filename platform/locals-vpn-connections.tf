locals {
  /*
   * Load the VPN connection YAML.
   */
  vpn_connections_config = yamldecode(
    file(var.vpn_connections_configuration_file)
  )

  /*
   * Normalize connection and link properties.
   */
  vpn_connections = {
    for connection_key, connection in try(
      local.vpn_connections_config.vpn_connections,
      {}
    ) :
    connection_key => {
      name     = try(connection.name, "vpnconn-${connection_key}")
      vpn_site = connection.vpn_site

      internet_security_enabled = try(
        connection.internet_security_enabled,
        false
      )

      links = {
        for link_key, link in connection.links :
        link_key => {
          /*
           * vpn_site_link refers to the link key or link name
           * in vpn-sites.yml.
           */
          vpn_site_link = try(
            link.vpn_site_link,
            link_key
          )

          shared_key_secret = link.shared_key_secret

          bgp_enabled = try(
            link.bgp_enabled,
            false
          )

          bandwidth_mbps = try(
            link.bandwidth_mbps,
            10
          )

          protocol = try(
            link.protocol,
            "IKEv2"
          )

          connection_mode = try(
            link.connection_mode,
            "Default"
          )

          route_weight = try(
            link.route_weight,
            0
          )

          dpd_timeout_seconds = try(
            link.dpd_timeout_seconds,
            45
          )

          ratelimit_enabled = try(
            link.ratelimit_enabled,
            false
          )

          local_azure_ip_address_enabled = try(
            link.local_azure_ip_address_enabled,
            false
          )

          policy_based_traffic_selector_enabled = try(
            link.policy_based_traffic_selector_enabled,
            false
          )

          ipsec_policy = try(
            link.ipsec_policy,
            null
          )
        }
      }
    }
  }

  /*
   * Build a flattened map for Key Vault secret data sources.
   *
   * Example key:
   * london/primary
   */
  vpn_psk_secret_references = merge([
    for connection_key, connection in local.vpn_connections : {
      for link_key, link in connection.links :
      "${connection_key}/${link_key}" => {
        connection_key = connection_key
        link_key       = link_key
        secret_name    = link.shared_key_secret
      }
    }
  ]...)

  /*
   * Build a map of links returned by each azurerm_vpn_site.
   *
   * Expected result:
   *
   * {
   *   london = {
   *     primary   = "<Azure link ID>"
   *     secondary = "<Azure link ID>"
   *   }
   * }
   */
  vpn_site_link_ids = {
    for site_key, site in azurerm_vpn_site.this :
    site_key => {
      for site_link in site.link :
      site_link.name => site_link.id
    }
  }

  /*
   * VPN Gateway IDs are keyed by the Virtual Hub keys:
   * emea and americas.
   
  vpn_gateway_ids = {
    for hub_key, gateway in azurerm_vpn_gateway.this :
    hub_key => gateway.id
  }
  */

  /*
   * Optional output-friendly connection map.
   */
  vpn_connection_ids = {
    for connection_key, connection
    in azurerm_vpn_gateway_connection.this :
    connection_key => connection.id
  }
}
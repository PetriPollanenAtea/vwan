resource "azurerm_vpn_gateway_connection" "this" {
  for_each = local.vpn_connections

  name = each.value.name

  vpn_gateway_id = local.vpn_gateway_ids[
    local.vpn_sites[each.value.vpn_site].hub
  ]

  remote_vpn_site_id = azurerm_vpn_site.this[
    each.value.vpn_site
  ].id

  internet_security_enabled = (
    each.value.internet_security_enabled
  )

  dynamic "vpn_link" {
    for_each = each.value.links

    content {
      name = vpn_link.key

      vpn_site_link_id = local.vpn_site_link_ids[
        each.value.vpn_site
      ][vpn_link.value.vpn_site_link]

      shared_key = data.azurerm_key_vault_secret.vpn_psk[
        "${each.key}/${vpn_link.key}"
      ].value

      bgp_enabled = vpn_link.value.bgp_enabled

      bandwidth_mbps = vpn_link.value.bandwidth_mbps

      protocol = vpn_link.value.protocol

      connection_mode = vpn_link.value.connection_mode

      route_weight = vpn_link.value.route_weight

      dpd_timeout_seconds = (
        vpn_link.value.dpd_timeout_seconds
      )

      ratelimit_enabled = (
        vpn_link.value.ratelimit_enabled
      )

      local_azure_ip_address_enabled = (
        vpn_link.value.local_azure_ip_address_enabled
      )

      policy_based_traffic_selector_enabled = (
        vpn_link.value.policy_based_traffic_selector_enabled
      )

      dynamic "ipsec_policy" {
        for_each = (
          vpn_link.value.ipsec_policy == null
          ? []
          : [vpn_link.value.ipsec_policy]
        )

        content {
          dh_group = ipsec_policy.value.dh_group

          ike_encryption_algorithm = (
            ipsec_policy.value.ike_encryption_algorithm
          )

          ike_integrity_algorithm = (
            ipsec_policy.value.ike_integrity_algorithm
          )

          encryption_algorithm = (
            ipsec_policy.value.encryption_algorithm
          )

          integrity_algorithm = (
            ipsec_policy.value.integrity_alogrithm
          )

          pfs_group = ipsec_policy.value.pfs_group

          sa_lifetime_sec = (
            ipsec_policy.value.sa_lifetime_sec
          )

          sa_data_size_kb = (
            ipsec_policy.value.sa_data_size_kb
          )
        }
      }
    }
  }
}
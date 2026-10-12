resource "azurerm_vpn_site" "this" {
  for_each = local.vpn_sites

  name = each.value.name

  resource_group_name = (
    local.virtual_wan.resource_group_name
  )

  location = local.virtual_wan.location

  virtual_wan_id = azurerm_virtual_wan.this.id

  /*
   * Combined private and selected public prefixes.
   */
  address_cidrs = each.value.address_prefixes

  device_vendor = each.value.device_vendor
  device_model  = each.value.device_model

  dynamic "link" {
    for_each = each.value.links

    content {
      name = link.value.name

      ip_address = link.value.ip_address
      fqdn       = link.value.fqdn

      provider_name = link.value.provider_name
      speed_in_mbps = link.value.speed_in_mbps
    }
  }

  lifecycle {
    precondition {
      condition = length(
        local.undefined_public_network_vpn_sites
      ) == 0

      error_message = format(
        "public-networks-via-onprem.yml references undefined VPN Sites: %s",
        jsonencode(
          local.undefined_public_network_vpn_sites
        )
      )
    }

    precondition {
      condition = length(
        local.invalid_public_network_prefixes
      ) == 0

      error_message = format(
        "Invalid CIDRs in public-networks-via-onprem.yml: %s",
        jsonencode(
          local.invalid_public_network_prefixes
        )
      )
    }

    precondition {
      condition = length(
        local.invalid_vpn_site_prefixes
      ) == 0

      error_message = format(
        "Invalid CIDRs in vpn-sites.yml: %s",
        jsonencode(
          local.invalid_vpn_site_prefixes
        )
      )
    }

    precondition {
      condition = length(
        local.prohibited_public_network_prefixes
      ) == 0

      error_message = format(
        "Default routes are prohibited in public-networks-via-onprem.yml. This configuration supports selected prefixes only: %s",
        jsonencode(
          local.prohibited_public_network_prefixes
        )
      )
    }

    precondition {
      condition = length(
        local.duplicate_public_prefixes_within_site
      ) == 0

      error_message = format(
        "Duplicate public prefixes were found within a VPN Site entry: %s",
        jsonencode(
          local.duplicate_public_prefixes_within_site
        )
      )
    }

    precondition {
      condition = length(
        local.duplicate_public_prefix_assignments
      ) == 0

      error_message = format(
        "The same public prefix must not be assigned to multiple VPN Sites: %s",
        jsonencode(
          local.duplicate_public_prefix_assignments
        )
      )
    }

    precondition {
      condition = length(
        local.vpn_sites_without_prefixes
      ) == 0

      error_message = format(
        "Each statically routed VPN Site must contain at least one address prefix: %s",
        jsonencode(
          local.vpn_sites_without_prefixes
        )
      )
    }

    precondition {
      condition = length(
        local.vpn_sites_without_links
      ) == 0

      error_message = format(
        "Every VPN Site must contain at least one link: %s",
        jsonencode(
          local.vpn_sites_without_links
        )
      )
    }

    precondition {
      condition = length(
        local.vpn_site_links_without_endpoint
      ) == 0

      error_message = format(
        "Every VPN Site link must define ip_address or fqdn: %s",
        jsonencode(
          local.vpn_site_links_without_endpoint
        )
      )
    }

    precondition {
      condition = length(
        local.vpn_site_links_with_multiple_endpoints
      ) == 0

      error_message = format(
        "A VPN Site link must define either ip_address or fqdn, not both: %s",
        jsonencode(
          local.vpn_site_links_with_multiple_endpoints
        )
      )
    }

    precondition {
      condition = length(
        local.vpn_sites_with_duplicate_link_names
      ) == 0

      error_message = format(
        "VPN Site link names must be unique within each site: %s",
        jsonencode(
          local.vpn_sites_with_duplicate_link_names
        )
      )
    }

    precondition {
      condition = length(
        local.invalid_vpn_site_link_speeds
      ) == 0

      error_message = format(
        "VPN Site link speed_in_mbps cannot be negative: %s",
        jsonencode(
          local.invalid_vpn_site_link_speeds
        )
      )
    }

    precondition {
      condition = length(
        local.vpn_sites_with_undefined_hubs
      ) == 0

      error_message = format(
        "VPN Sites reference undefined Virtual Hubs: %s",
        jsonencode(
          local.vpn_sites_with_undefined_hubs
        )
      )
    }
  }
}
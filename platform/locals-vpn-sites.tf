locals {
  /*
   * Load YAML configuration files.
   */
  vpn_sites_config = yamldecode(
    file(var.vpn_sites_configuration_file)
  )
  public_networks_via_onprem_config = yamldecode(
    file(
      var.public_networks_via_onprem_configuration_file
    )
  )

  /*
   * Unmodified source configuration.
   */
  vpn_sites_raw = try(
    local.vpn_sites_config.vpn_sites,
    {}
  )
  public_networks_via_onprem_raw = try(
    local.public_networks_via_onprem_config.public_networks_via_onprem,
    {}
  )

  /*
   * Normalize the public-prefix configuration.
   */
  public_networks_via_onprem = {
    for site_key, configuration
    in local.public_networks_via_onprem_raw :
    site_key => {
      address_prefixes = try(
        configuration.address_prefixes,
        []
      )
    }
  }

  /*
   * Normalize VPN Sites and merge the selected public
   * prefixes into address_prefixes.
   */
  vpn_sites = {
    for site_key, site in local.vpn_sites_raw :
    site_key => {
      hub  = site.hub
      name = site.name
      device_vendor = try(
        site.device_vendor,
        null
      )
      device_model = try(
        site.device_model,
        null
      )

      /*
       * Combined route inventory presented to Azure:
       *
       * 1. Normal on-premises site prefixes
       * 2. Selected public prefixes routed through the site
       */
      address_prefixes = distinct(
        concat(
          try(
            site.address_prefixes,
            []
          ),
          try(
            local.public_networks_via_onprem[
              site_key
            ].address_prefixes,
            []
          )
        )
      )

      /*
       * Preserve these separately for diagnostics and outputs.
       */
      private_address_prefixes = distinct(
        try(
          site.address_prefixes,
          []
        )
      )
      public_address_prefixes = distinct(
        try(
          local.public_networks_via_onprem[
            site_key
          ].address_prefixes,
          []
        )
      )
      links = {
        for link_key, link in try(site.links, {}) :
        link_key => {
          name = try(
            link.name,
            link_key
          )
          ip_address = try(
            link.ip_address,
            null
          )
          fqdn = try(
            link.fqdn,
            null
          )
          provider_name = try(
            link.provider_name,
            null
          )
          speed_in_mbps = try(
            link.speed_in_mbps,
            0
          )
        }
      }
    }
  }
}
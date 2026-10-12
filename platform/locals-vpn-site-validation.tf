locals {
  /*
   * Public-prefix configuration keys that do not correspond
   * to a VPN Site.
   */
  undefined_public_network_vpn_sites = {
    for site_key, configuration
    in local.public_networks_via_onprem :

    site_key => configuration.address_prefixes

    if !contains(
      keys(local.vpn_sites_raw),
      site_key
    )
  }

  /*
   * Invalid public-network CIDRs.
   */
  invalid_public_network_prefixes = {
    for item in flatten([
      for site_key, configuration
      in local.public_networks_via_onprem : [

        for prefix in configuration.address_prefixes : {
          key    = "${site_key}/${prefix}"
          site   = site_key
          prefix = prefix
        }

        if !can(
          cidrhost(prefix, 0)
        )
      ]
    ]) :

    item.key => {
      vpn_site = item.site
      prefix   = item.prefix
    }
  }

  /*
   * Invalid normal VPN Site CIDRs.
   */
  invalid_vpn_site_prefixes = {
    for item in flatten([
      for site_key, site in local.vpn_sites_raw : [

        for prefix in try(site.address_prefixes, []) : {
          key    = "${site_key}/${prefix}"
          site   = site_key
          prefix = prefix
        }

        if !can(
          cidrhost(prefix, 0)
        )
      ]
    ]) :

    item.key => {
      vpn_site = item.site
      prefix   = item.prefix
    }
  }

  /*
   * Block accidental full forced tunneling.
   */
  prohibited_public_network_prefixes = {
    for item in flatten([
      for site_key, configuration
      in local.public_networks_via_onprem : [

        for prefix in configuration.address_prefixes : {
          key    = "${site_key}/${prefix}"
          site   = site_key
          prefix = prefix
        }

        if prefix == "0.0.0.0/0" ||
        prefix == "::/0"
      ]
    ]) :

    item.key => {
      vpn_site = item.site
      prefix   = item.prefix
    }
  }

  /*
   * Duplicate prefixes within one public-prefix site entry.
   */
  duplicate_public_prefixes_within_site = {
    for site_key, configuration
    in local.public_networks_via_onprem :

    site_key => {
      for prefix in distinct(
        configuration.address_prefixes
      ) :

      prefix => length([
        for candidate in configuration.address_prefixes :
        candidate
        if candidate == prefix
      ])

      if length([
        for candidate in configuration.address_prefixes :
        candidate
        if candidate == prefix
      ]) > 1
    }

    if length(
      distinct(configuration.address_prefixes)
    ) != length(configuration.address_prefixes)
  }

  /*
   * Flatten public prefix ownership.
   */
  public_prefix_assignments = flatten([
    for site_key, configuration
    in local.public_networks_via_onprem : [

      for prefix in distinct(
        configuration.address_prefixes
        ) : {
        site_key = site_key
        prefix   = prefix
      }
    ]
  ])

  /*
   * A public prefix must not be assigned to several VPN Sites.
   */
  duplicate_public_prefix_assignments = {
    for prefix in distinct([
      for assignment in local.public_prefix_assignments :
      assignment.prefix
    ]) :

    prefix => [
      for assignment in local.public_prefix_assignments :
      assignment.site_key
      if assignment.prefix == prefix
    ]

    if length([
      for assignment in local.public_prefix_assignments :
      assignment
      if assignment.prefix == prefix
    ]) > 1
  }

  /*
   * VPN Sites without address prefixes.
   *
   * This implementation uses static routing rather than BGP,
   * so each site must have at least one merged prefix.
   */
  vpn_sites_without_prefixes = {
    for site_key, site in local.vpn_sites :

    site_key => site.name

    if length(
      site.address_prefixes
    ) == 0
  }

  /*
   * VPN Sites without any links.
   */
  vpn_sites_without_links = {
    for site_key, site in local.vpn_sites :

    site_key => site.name

    if length(
      site.links
    ) == 0
  }

  /*
   * Links must contain either an IP address or an FQDN.
   */
  vpn_site_links_without_endpoint = {
    for item in flatten([
      for site_key, site in local.vpn_sites : [

        for link_key, link in site.links : {
          key      = "${site_key}/${link_key}"
          site_key = site_key
          link_key = link_key
        }

        if link.ip_address == null &&
        link.fqdn == null
      ]
    ]) :

    item.key => {
      vpn_site = item.site_key
      link     = item.link_key
    }
  }

  /*
   * A link must not define both endpoint forms.
   */
  vpn_site_links_with_multiple_endpoints = {
    for item in flatten([
      for site_key, site in local.vpn_sites : [

        for link_key, link in site.links : {
          key      = "${site_key}/${link_key}"
          site_key = site_key
          link_key = link_key
        }

        if link.ip_address != null &&
        link.fqdn != null
      ]
    ]) :

    item.key => {
      vpn_site = item.site_key
      link     = item.link_key
    }
  }

  /*
   * Link names must be unique inside each VPN Site.
   */
  vpn_sites_with_duplicate_link_names = {
    for site_key, site in local.vpn_sites :

    site_key => [
      for link in values(site.links) :
      link.name
    ]

    if length([
      for link in values(site.links) :
      lower(link.name)
      ]) != length(
      distinct([
        for link in values(site.links) :
        lower(link.name)
      ])
    )
  }

  /*
   * Validate speed values.
   */
  invalid_vpn_site_link_speeds = {
    for item in flatten([
      for site_key, site in local.vpn_sites : [

        for link_key, link in site.links : {
          key      = "${site_key}/${link_key}"
          site_key = site_key
          link_key = link_key
          speed    = link.speed_in_mbps
        }

        if link.speed_in_mbps < 0
      ]
    ]) :

    item.key => {
      vpn_site      = item.site_key
      link          = item.link_key
      speed_in_mbps = item.speed
    }
  }

  /*
   * VPN Site keys must refer to known regional Virtual Hubs.
   */
  vpn_sites_with_undefined_hubs = {
    for site_key, site in local.vpn_sites :

    site_key => site.hub

    if !contains(
      keys(local.virtual_hubs),
      site.hub
    )
  }
}

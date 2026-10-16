locals {
  firewalls_config = yamldecode(
    file(var.firewalls_configuration_file)
  )
  firewalls_raw = try(
    local.firewalls_config.firewalls,
    {}
  )
  firewalls = {
    for firewall_key, firewall
    in local.firewalls_raw :
    firewall_key => {
      name = try(
        firewall.name,
        null
      )
      hub = try(
        firewall.virtual_hub,
        null
      )
      policy = try(
        firewall.firewall_policy,
        null
      )
      sku_tier = try(
        firewall.sku_tier,
        "Standard"
      )
      threat_intel_mode = try(
        firewall.threat_intel_mode,
        "Alert"
      )
      public_ip_prefix = {
        name = try(
          firewall.public_ip_prefix.name,
          null
        )
        prefix_length = try(
          firewall.public_ip_prefix.prefix_length,
          null
        )
        firewall_ip_count = try(
          firewall.public_ip_prefix.firewall_ip_count,
          null
        )
      }
    }
  }
}
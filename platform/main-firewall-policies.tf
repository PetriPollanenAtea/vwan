resource "azurerm_firewall_policy" "parent" {
  for_each = {
    for key, policy in local.firewall_policies :
    key => policy
    if !contains(
      keys(policy),
      "parent"
    )
  }

  name                = each.value.name
  resource_group_name = each.value.resource_group_name
  location            = each.value.location
  sku = try(
    each.value.sku,
    "Basic"
  )

  threat_intelligence_mode = try(
    each.value.threat_intelligence_mode,
    "Off"
  )

  private_ip_ranges = try(
    each.value.private_ip_ranges,
    null
  )

  dynamic "dns" {
    for_each = try(
      [each.value.dns],
      []
    )

    content {
      proxy_enabled = try(
        dns.value.proxy_enabled,
        false
      )

      servers = try(
        dns.value.servers,
        []
      )
    }
  }
}

resource "azurerm_firewall_policy" "child" {
  for_each = {
    for key, policy in local.firewall_policies :
    key => policy
    if contains(
      keys(policy),
      "parent"
    )
  }

  name                = each.value.name
  resource_group_name = each.value.resource_group_name
  location            = each.value.location
  sku = try(
    each.value.sku,
    "Basic"
  )

  threat_intelligence_mode = try(
    each.value.threat_intelligence_mode,
    "Off"
  )

  base_policy_id = azurerm_firewall_policy.parent[
    each.value.parent
  ].id

  private_ip_ranges = try(
    each.value.private_ip_ranges,
    null
  )

  dynamic "dns" {
    for_each = try(
      [each.value.dns],
      []
    )

    content {
      proxy_enabled = try(
        dns.value.proxy_enabled,
        false
      )

      servers = try(
        dns.value.servers,
        []
      )
    }
  }
}
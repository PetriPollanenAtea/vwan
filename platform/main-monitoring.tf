resource "azurerm_log_analytics_workspace" "this" {
  name                = local.monitoring.log_analytics.name
  resource_group_name = local.monitoring.log_analytics.resource_group_name
  location            = local.monitoring.log_analytics.location
  sku                 = "PerGB2018"
  retention_in_days   = local.monitoring.log_analytics.retention_in_days
}

/*
resource "azurerm_monitor_diagnostic_setting" "virtual_wan" {
  name                       = "diag-vwan"
  target_resource_id         = azurerm_virtual_wan.this.id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.this.id
  enabled_log {
    category = "AllLogs"
  }
  metric {
    category = "AllMetrics"
  }
}

resource "azurerm_monitor_diagnostic_setting" "virtual_hubs" {
  for_each                   = azurerm_virtual_hub.this
  name                       = "diag-${each.key}"
  target_resource_id         = each.value.id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.this.id
  enabled_log {
    category = "AllLogs"
  }
  metric {
    category = "AllMetrics"
  }
}

resource "azurerm_monitor_diagnostic_setting" "firewall_policies" {
  for_each = merge(
    azurerm_firewall_policy.parent,
    azurerm_firewall_policy.child
  )
  name                       = "diag-${each.key}"
  target_resource_id         = each.value.id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.this.id
  enabled_log {
    category = "AllLogs"
  }
  metric {
    category = "AllMetrics"
  }
}

*/



resource "azurerm_monitor_diagnostic_setting" "vpn_gateways" {
  for_each                   = azurerm_vpn_gateway.this
  name                       = "diag-${each.key}"
  target_resource_id         = each.value.id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.this.id
  enabled_log {
    category = "GatewayDiagnosticLog"
  }
  enabled_log {
    category = "TunnelDiagnosticLog"
  }
  enabled_log {
    category = "RouteDiagnosticLog"
  }
  enabled_log {
    category = "IKEDiagnosticLog"
  }
  metric {
    category = "AllMetrics"
  }
}

resource "azurerm_monitor_diagnostic_setting" "firewalls" {
  for_each                   = azurerm_firewall.this
  name                       = "diag-${each.key}"
  target_resource_id         = each.value.id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.this.id
  enabled_log {
    category = "AzureFirewallApplicationRule"
  }
  enabled_log {
    category = "AzureFirewallNetworkRule"
  }
  enabled_log {
    category = "AzureFirewallDnsProxy"
  }
  enabled_log {
    category = "AZFWNetworkRule"
  }
  enabled_log {
    category = "AZFWApplicationRule"
  }
  enabled_log {
    category = "AZFWDnsQuery"
  }
  enabled_log {
    category = "AZFWFqdnResolveFailure"
  }
  metric {
    category = "AllMetrics"
  }
}

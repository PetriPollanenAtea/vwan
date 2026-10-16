resource "azurerm_log_analytics_workspace" "this" {
  name                = local.monitoring.log_analytics.name
  resource_group_name = local.monitoring.log_analytics.resource_group_name
  location            = local.monitoring.log_analytics.location
  sku                 = "PerGB2018"
  retention_in_days   = local.monitoring.log_analytics.retention_in_days
}
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
  enabled_metric {
    category = "AllMetrics"
  }
}

resource "azurerm_monitor_diagnostic_setting" "firewalls" {
  for_each = local.firewall_ids

  name = "diag-${each.key}"

  target_resource_id = each.value

  log_analytics_workspace_id = (
    azurerm_log_analytics_workspace.this.id
  )

  enabled_log {
    category = "AZFWNetworkRule"
  }

  enabled_log {
    category = "AZFWApplicationRule"
  }

  enabled_log {
    category = "AZFWNatRule"
  }

  enabled_log {
    category = "AZFWDnsQuery"
  }

  enabled_log {
    category = "AZFWFqdnResolveFailure"
  }

  enabled_log {
    category = "AZFWThreatIntel"
  }

  enabled_log {
    category = "AZFWIdpsSignature"
  }

  enabled_metric {
    category = "AllMetrics"
  }
}

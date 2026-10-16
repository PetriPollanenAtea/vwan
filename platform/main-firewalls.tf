resource "azapi_resource" "firewall" {
  for_each = local.firewalls

  type = "Microsoft.Network/azureFirewalls@2025-05-01"

  name = each.value.name

  parent_id = format(
    "/subscriptions/%s/resourceGroups/%s",
    data.azurerm_client_config.current.subscription_id,
    local.virtual_hubs[
      each.value.hub
    ].resource_group_name
  )

  location = local.virtual_hubs[
    each.value.hub
  ].location

  body = {
    properties = {
      sku = {
        name = "AZFW_Hub"
        tier = each.value.sku_tier
      }

      virtualHub = {
        id = azurerm_virtual_hub.this[
          each.value.hub
        ].id
      }

      firewallPolicy = {
        id = local.firewall_policy_ids[
          each.value.policy
        ]
      }

      # Customer-provided public IPs (from the public IP prefix).
      # No hubIPAddresses block: that is the hub-managed path.
      ipConfigurations = [
        for i, pip_id in local.firewall_public_ip_ids[each.key] : {
          name = format("ipconfig-%02d", i + 1)
          properties = {
            publicIPAddress = {
              id = pip_id
            }
          }
        }
      ]

      # threatIntelMode = "Alert"
    }
  }

  response_export_values = [
    "properties.hubIPAddresses",
    "properties.ipConfigurations",
    "properties.provisioningState"
  ]

  ignore_missing_property = true

  depends_on = [
    terraform_data.firewall_validation,
    azurerm_public_ip.firewall
  ]

  lifecycle {
    precondition {
      condition = alltrue([
        for address
        in local.firewall_public_ip_addresses[
          each.key
        ] :

        address != null &&
        length(trimspace(address)) > 0
      ])

      error_message = format(
        "One or more Public IP addresses for firewall '%s' were not allocated.",
        each.value.name
      )
    }
  }
}
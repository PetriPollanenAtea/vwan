resource "azurerm_public_ip_prefix" "firewall" {
  for_each = local.firewall_public_ip_prefixes

  name = each.value.name

  resource_group_name = (
    each.value.resource_group_name
  )

  location = each.value.location

  prefix_length = each.value.prefix_length

  sku      = "Standard"
  sku_tier = "Regional"

  ip_version = "IPv4"

  depends_on = [
    terraform_data.firewall_validation
  ]
}
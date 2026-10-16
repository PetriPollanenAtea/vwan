resource "azurerm_public_ip" "firewall" {
  for_each = local.firewall_public_ips

  name = each.value.name

  resource_group_name = (
    each.value.resource_group_name
  )

  location = each.value.location

  allocation_method = "Static"

  sku      = "Standard"
  sku_tier = "Regional"

  ip_version = "IPv4"

  public_ip_prefix_id = (
    azurerm_public_ip_prefix.firewall[
      each.value.firewall_key
    ].id
  )

  depends_on = [
    terraform_data.firewall_validation
  ]
}
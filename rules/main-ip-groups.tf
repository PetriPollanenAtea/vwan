resource "azurerm_ip_group" "this" {
  for_each            = local.ip_groups
  name                = each.value.name
  resource_group_name = each.value.resource_group_name
  location            = each.value.location
  cidrs               = each.value.cidrs
}
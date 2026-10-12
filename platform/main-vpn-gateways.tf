resource "azurerm_vpn_gateway" "this" {
  for_each            = local.virtual_hubs
  name                = "${each.value.name}-vpngw"
  resource_group_name = each.value.resource_group_name
  location            = each.value.location
  virtual_hub_id = azurerm_virtual_hub.this[
    each.key
  ].id
  scale_unit = 1
  tags = try(
    each.value.tags,
    {}
  )
}
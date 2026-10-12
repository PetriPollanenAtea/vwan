resource "azurerm_virtual_wan" "this" {
  name                = local.virtual_wan.name
  resource_group_name = local.virtual_wan.resource_group_name
  location            = local.virtual_wan.location

  type = try(
    local.virtual_wan.type,
    "Standard"
  )

  allow_branch_to_branch_traffic = try(
    local.virtual_wan.allow_branch_to_branch_traffic,
    true
  )

  disable_vpn_encryption = try(
    local.virtual_wan.disable_vpn_encryption,
    false
  )

  tags = try(
    local.virtual_wan.tags,
    {}
  )
}

resource "azurerm_virtual_hub" "this" {
  for_each = local.virtual_hubs

  name                = each.value.name
  resource_group_name = each.value.resource_group_name
  location            = each.value.location
  virtual_wan_id      = azurerm_virtual_wan.this.id
  address_prefix      = each.value.address_prefix
  sku                 = each.value.sku

  hub_routing_preference = (
    each.value.hub_routing_preference
  )

  tags = each.value.tags
}
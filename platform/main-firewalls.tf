resource "azurerm_firewall" "this" {
  /*depends_on = [ 
    azurerm_virtual_wan.this,
    azazurerm_virtual_hub.this
  ]*/
  for_each = local.firewalls
  name     = each.value.name
  location = azurerm_virtual_hub.this[
    each.value.virtual_hub
  ].location
  resource_group_name = azurerm_virtual_hub.this[
    each.value.virtual_hub
  ].resource_group_name
  sku_name = "AZFW_Hub"
  sku_tier = try(
    each.value.sku_tier,
    "Premium"
  )
  firewall_policy_id = local.firewall_policy_ids[
    each.value.firewall_policy
  ]
  virtual_hub {
    virtual_hub_id = azurerm_virtual_hub.this[
      each.value.virtual_hub
    ].id
    public_ip_count = try(
      each.value.public_ip_count,
      2
    )
  }
}
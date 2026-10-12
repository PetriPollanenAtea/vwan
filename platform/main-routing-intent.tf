resource "azurerm_virtual_hub_routing_intent" "this" {
  for_each = local.routing_intents
  name     = "routing-intent"
  virtual_hub_id = azurerm_virtual_hub.this[
    each.key
  ].id
  routing_policy {
    name = "InternetTraffic"
    destinations = [
      "Internet"
    ]
    next_hop = azurerm_firewall.this[
      each.key
    ].id
  }
  routing_policy {
    name = "PrivateTraffic"
    destinations = [
      "PrivateTraffic"
    ]
    next_hop = azurerm_firewall.this[
      each.key
    ].id
  }
}
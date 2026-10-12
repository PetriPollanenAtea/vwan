output "firewalls" {
  value = {
    for key, firewall
    in azurerm_firewall.this :
    key => {
      id        = firewall.id
      name      = firewall.name
      policy_id = firewall.firewall_policy_id
      location  = firewall.location
    }
  }
}

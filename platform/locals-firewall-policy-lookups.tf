locals {
  firewall_policy_ids = merge(
    {
      for key, policy
      in azurerm_firewall_policy.parent :
      key => policy.id
    },
    {
      for key, policy
      in azurerm_firewall_policy.child :
      key => policy.id
    }
  )
}
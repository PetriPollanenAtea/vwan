module "virtual_hub_connection" {
  source = "./modules/virtual-hub-connection"

  for_each = local.virtual_hub_connections

  name = each.value.name

  virtual_hub_id = local.virtual_hub_ids[
    each.value.virtual_hub
  ]

  remote_virtual_network_id = local.all_virtual_network_ids[
    each.value.virtual_network
  ]

  internet_security_enabled = (
    each.value.internet_security_enabled
  )
}
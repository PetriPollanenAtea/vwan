module "virtual_network" {
  source = "./modules/virtual-network"

  for_each = local.virtual_networks

  name                = each.value.name
  resource_group_name = each.value.resource_group_name
  location            = each.value.location
  address_space       = each.value.address_space
  dns_servers         = each.value.dns_servers
  subnets             = each.value.subnets
  tags                = each.value.tags
}
locals {
  firewall_ids = {
    for firewall_key, firewall
    in azapi_resource.firewall :

    firewall_key => firewall.id
  }

  firewall_public_ip_prefix_ids = {
    for firewall_key, prefix
    in azurerm_public_ip_prefix.firewall :

    firewall_key => prefix.id
  }

  /*
  firewall_public_ip_ids = {
    for firewall_key, firewall
    in local.firewalls :

    firewall_key => [
      for index in range(
        firewall.public_ip_prefix.firewall_ip_count
      ) :

      azurerm_public_ip.firewall[
        "${firewall_key}/${index}"
      ].id
    ]
  }
  */

  # Public IP resource IDs per firewall, in index order.
  # Needed because ipConfigurations references IPs by resource ID, not by address.
  firewall_public_ip_ids = {
    for firewall_key, prefix
    in local.firewall_public_ip_prefixes :

    firewall_key => [
      for index in range(try(prefix.firewall_ip_count, 0)) :
      azurerm_public_ip.firewall["${firewall_key}/${index}"].id
    ]
  }
}
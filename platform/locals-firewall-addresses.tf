locals {
  firewall_public_ip_addresses = {
    for firewall_key, firewall
    in local.firewalls :

    firewall_key => [
      for index in range(
        firewall.public_ip_prefix.firewall_ip_count
      ) :

      azurerm_public_ip.firewall[
        "${firewall_key}/${index}"
      ].ip_address
    ]
  }

  firewall_public_ip_address_objects = {
    for firewall_key, addresses
    in local.firewall_public_ip_addresses :

    firewall_key => [
      for address in addresses : {
        address = address
      }
    ]
  }
}
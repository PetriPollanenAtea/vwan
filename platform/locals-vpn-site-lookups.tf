locals {

  vpn_site_ids = {
    for site_key, site in azurerm_vpn_site.this :
    site_key => site.id
  }

}